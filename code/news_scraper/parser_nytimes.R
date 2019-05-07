parser_nytimes_articles <- function(folderInput) {
  # load packages
  require(rvest)
  require(purrr)
  require(magrittr)
  require(lubridate)
  require(stringr)
  require(textclean)
  # import htmls
  htmls <- list.files(folderInput, pattern = "html$", recursive = TRUE, full.names = TRUE)
  html_list <- lapply(htmls, possibly(read_html, NA))
  html_list <- html_list[!is.na(html_list)]
  # author field cleaner function
  author_cleaner <- function(x) {
    x <- x %>% 
      str_replace("^By ", "") %>% 
      str_replace(" and ", ", ") %>%
      replace_white()
    x
  }
  # text field cleaner function
  text_cleaner <- function(x) {
    x <- x %>%
      replace_white
    x  
  } 
  # parse info
  url_orig <- page_parser_xpath(html_list, "//meta[@property='og:url']", attr = "content")
  topic_tags <- page_parser_xpath(html_list, "//meta[@name='news_keywords']", attr = "content")
  headline <- page_parser_xpath(html_list, "//h1[@itemprop='headline']/span")
  datetime <- page_parser_xpath(html_list, "//meta[@itemprop='datePublished']", attr = "content") %>% str_replace(".000Z", "") %>% parse_date_time("ymd HMS", tz = "America/New_York")
  domain <- page_parser_xpath(html_list, "//meta[@itemprop='articleSection']", attr = "content")
  author <- page_parser_xpath(html_list, "//meta[@name='byl']", attr = "content") %>% author_cleaner()
  text <- page_parser(html_list, ".e2kc3sl0", multi = TRUE) %>% text_cleaner()
  # merge to data frame; return
  articles_dat <- data.frame(outlet = "nytimes",
                             outlet_url = "https://www.nytimes.com/",
                             datetime,
                             url_orig, 
                             headline, 
                             author,
                             domain,
                             topic_tags,
                             text,
                             stringsAsFactors = FALSE
                             )
  articles_dat <- filter(articles_dat, str_length(text) > 0)
  articles_dat <- articles_dat[!duplicated(nytimes_df$url_orig),]
  articles_dat
  } # function end
  


# prepare
library(tidyverse)
source("parser_functions.R")
outlet <- "nytimes"
folder <- "../data/nytimes/articles_unpacked"

# rename files
all_files <- list.files(folder, recursive = TRUE, full.names = TRUE)
all_files_newname <- str_replace(all_files, fixed("?partner=rss&emc=rss"), "")
file.rename(all_files, all_files_newname)

# remove duplicate downloads
duplicates <- list.files(folder, pattern = " 2html$", recursive = TRUE, full.names = TRUE)
file.remove(duplicates)

# remove empty files
all_files <- list.files(folder, pattern = "html$", recursive = TRUE, full.names = TRUE)
empty_files <- all_files[sapply(all_files, file.size) == 0]
empty_files_df <- file.info(empty_files) %>% select(mtime, size)
empty_files_df$href <- basename(empty_files)
empty_files_df$outlet <- outlet
datetime <- str_replace_all(Sys.time(), "[ :]", "-")
write_csv(empty_files_df, paste0("download_logs/empty_files_", outlet, "_", datetime, ".csv"))
file.remove(empty_files)

# parse and store data
nytimes_df <- parser_nytimes_articles(folder)
save(nytimes_df, file = "../data_parsed/nytimes_df_2018_june.RDa")

load("../data_parsed/nytimes_df_2018_june.RDa")
View(nytimes_df)
# examine coverage
dates_df <- data.frame(as.Date(nytimes_df$datetime, "%Y-%m-%d") %>% table, stringsAsFactors = FALSE)
names(dates_df) <- c("date", "count")
plot(dates_df$date, dates_df$count)



