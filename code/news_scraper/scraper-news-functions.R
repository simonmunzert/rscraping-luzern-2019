news_rss_scraper <- function(outlet = "") {
  # load packages
  require(stringr)
  require(magrittr)
  require(xml2)
  require(readr)
  require(dplyr)
  # check outlet
  if(str_count(outlet) == 0){
    stop("Please provide an outlet name!")
  }
  # get RSS
  rss_feeds <- read_csv("rss-feeds.csv", quote = '"') %>% .[.$outlet == outlet,] %>% .$rss
  rss_out_list <- lapply(rss_feeds, read_xml)
  # create folder
  folder <- paste0("../data/", outlet, "/rss")
  dir.create(folder, showWarnings = FALSE, recursive = TRUE)
  # write raw RSS
  datetime <- format(as.POSIXct(Sys.time(), tz = Sys.timezone()), usetz = TRUE)  %>% as.character() %>% str_replace_all("[ :]", "-")
  rss_feeds <- rss_feeds %>% 
    str_replace(fixed("?service=Rss"), "") %>% # abendblatt
    str_replace(fixed("@@RSS"), "") %>% # freitag
    str_replace("/index.rss$", "") %>% # gmx, spiegel, webde
    str_replace(fixed("/index.rss?output=rss"), "") %>% # sueddeutsche
    str_replace("/index$", "") %>% # zeit
    str_replace(fixed("?format=xml"), "")  %>% # breitbart, time
    str_replace("/rss.xml$", "")  %>% # economist, bbcnews
    str_replace("/rss$", "")  %>% # guardian, yahoous, vice
    str_replace("&x=1", "")  %>% # usa today
    str_replace(fixed("/rss.php?id=1001"), "")  %>% # npr
    str_replace(fixed("/feeds/site.xml"), "")  %>% #  bloomberg
    str_replace(fixed("/device/rss/rss.html"), "")  %>% #  cnbc
    str_replace(fixed("/rss2.0.xml"), "")  %>% #  latimes
    str_replace(fixed("/?output=rss"), "")  %>% #  googlenewsus, googlenewsde
    str_replace(fixed("/rss.xml?edition=us"), "")  %>% # bbcnews
    str_replace("/feed$", "")  # huffingtonpost, motherjones, thinkprogress
  filepaths <-paste0(folder, "/", outlet, "-", datetime, "-", basename(rss_feeds), ".rss")
  Map(function(x, filepath) write_xml(x, file = filepath, w, options = "format"), rss_out_list, filepaths)
}

news_articles_scraper <- function(outlet = "", feedburner = FALSE) {
  # load packages
  require(httr)
  require(rvest)
  require(stringr)
  require(magrittr)
  require(R.utils)
  # check date
  datetime <- format(as.POSIXct(Sys.time(), tz = Sys.timezone()), usetz = TRUE)  %>% as.character() %>% str_replace_all("[ :]", "-")
  SysDate <- Sys.Date() %>% as.character()
  SysDateYesterday <- (Sys.Date() - 1) %>% as.character()
  # creater folder names
  folderInput <- paste0("../data/", outlet, "/rss")
  folderOutput <- paste0("../data/", outlet, "/articles/", SysDate)
  folderOutputYesterday <- paste0("../data/", outlet, "/articles/", SysDateYesterday)
  dir.create(folderOutput, showWarnings = FALSE, recursive = TRUE)
  # import xmls
  xmls <- list.files(folderInput, pattern = paste0(outlet, ".+rss$"), full.names = TRUE)
  xmls <- xmls[str_detect(xmls, SysDate)] # pick only files from this day
  xmls_parsed <- lapply(xmls, read_xml)
  if(feedburner == TRUE){
    urls_parsed <- lapply(xmls_parsed, function(x) { xml_find_all(x, ".//feedburner:origLink", xml_ns(x)) %>% xml_text}) %>% unlist %>% unique()
  }
  if(feedburner == FALSE){
    urls_parsed <- lapply(xmls_parsed, function(x) { xml_nodes(x, "link") %>% xml_text}) %>% unlist %>% unique()
  }
  # download article htmls
  dir.create(folderOutput, showWarnings = FALSE, recursive = TRUE)
  urls_articles <- urls_parsed %>% unlist 
  sapply(urls_articles, function(x){
      destfile <- paste0(folderOutput, "/", basename(x))
      if(!file.exists(destfile)) {
        withTimeout({try(download.file(x, destfile = destfile, method = "libcurl"))},
                        timeout = 5,
                        onTimeout = "silent")
      }
  })
  # write report
  article_report <- data.frame(datetime = datetime,
             outlet = outlet, 
             n_articles = list.files(folderOutput) %>% length(),
             n_articles_empty = sum(list.files(folderOutput, full.names = TRUE) %>% file.size() == 0), stringsAsFactors = FALSE)
  write_csv(article_report, "article-reports.csv", append = TRUE, col_names = FALSE)
  # delete corrupted files
  files_to_delete <- list.files(folderOutput, full.names = TRUE)[list.files(folderOutput, full.names = TRUE) %>% file.size() == 0]
  unlink(files_to_delete)
  # zip article folder; delete unzipped data
  zip(paste0(folderOutput, ".zip"), folderOutput)
  unlink(folderOutputYesterday, recursive = TRUE)
}

outlet <- "huffingtonpost"
feedburner = FALSE


news_frontpage_scraper <- function(outlet = "") {
  # load packages
  require(httr)
  require(rvest)
  require(stringr)
  require(magrittr)
  require(R.utils)
  # check datetime
  datetime <- format(as.POSIXct(Sys.time(), tz = Sys.timezone()), usetz = TRUE)  %>% as.character() %>% str_replace_all("[ :]", "-")
  outlet_url <- read_csv("rss-feeds.csv", quote = '"') %>% .[.$outlet == outlet,] %>%
 .$outlet_url %>% unique
  folderOutput <- paste0("../data/", outlet, "/frontpages")
  dir.create(folderOutput, showWarnings = FALSE, recursive = TRUE)
  destfile <- paste0(folderOutput, "/", outlet, "-", datetime, ".html")
  withTimeout({
        try(download.file(outlet_url, destfile = destfile, method = "libcurl"))},
                  timeout = 10,
                  onTimeout = "silent")
}


