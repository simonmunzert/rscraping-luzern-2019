### -----------------------------
### simon munzert
### intro to web scraping with R
### solutions to exercises
### -----------------------------


source("packages.r")


## regular expressions ---------------------------------------

## 1. describe the types of strings that conform to the following regular expressions and construct an example that is matched by the regular expression.
str_extract_all("Phone 150$, PC 690$", "[0-9]+\\$") # example
str_extract_all("Just any sentence, I don't know. Today is a nice day.", "\\b[a-z]{1,4}\\b")
str_extract_all(c("log.txt", "example.html", "bla.txt2"), ".*?\\.txt$")
str_extract_all("log.txt, example.html, bla.txt2", ".*?\\.txt$")
str_extract_all(c("01/01/2000", "1/1/00", "01.01.2000"), "\\d{2}/\\d{2}/\\d{4}")
str_extract_all(c("<br>laufen</br>", "<title>Cameron wins election</title>"), "<(.+?)>.+?</\\1>")

## 2. consider the mail address  chunkylover53[at]aol[dot]com.
# a) transform the string to a standard mail format using regular expressions.
# b) imagine we are trying to extract the digits in the mail address using [:digit:]. explain why this fails and correct the expression.
email <- "chunkylover53[at]aol[dot]com"
email_new <- email %>% str_replace("\\[at\\]", "@") %>% str_replace("\\[dot\\]", ".")
str_extract(email_new, "[:digit:]+")




## scraping static pages ---------------------------------------

# 1. go to the following website
browseURL("https://www.jstatsoft.org/about/editorialTeam")
# a) which HTML features can be used to describe all names of the editorial team?
# b) write a corresponding XPath expression that targets them, and apply it using rvest!

url <- "https://www.jstatsoft.org/about/editorialTeam"
url_parsed <- read_html(url)
html_nodes(url_parsed, xpath = "//div[@class = 'member']//a") %>% html_text()

# c) bonus: try and extract the full lines including the affiliation and count how many of the editors are at a statistics or mathematics department or institution!

affiliations <- html_nodes(url_parsed, xpath = "//div[@class = 'member']/li") %>% html_text()
str_detect(affiliations, "tatisti|athemati") %>% table


# 2. consider the table of tall buildings (300m+) currently under construction from https://en.wikipedia.org/wiki/List_of_tallest_buildings_in_the_world".

# a) scrape it.

url <- "https://en.wikipedia.org/wiki/List_of_tallest_buildings_in_the_world"
url_parsed <- read_html(url)
 tables <- html_table(url_parsed, fill = TRUE)
buildings <- tables[[6]]


# b) how many of those buildings are currently built in China? and in which city are most of the tallest buildings currently built?
table(buildings$`Country`) %>% sort
table(buildings$City) %>% sort

# c) what is the sum of heights of all of these buildings?
str_extract(buildings$`Planned architectural height`, "[[:digit:],.]+") %>% str_replace(",", "") %>% as.numeric() %>% sum


## tapping APIs ----------

# 1. familiarize yourself with the WikipediR package! 
browseURL("https://cran.r-project.org/web/packages/WikipediR/vignettes/WikipediR.html")

# a) what functions does it provide and what do they do?
# b) use the package to get content, links, and backlinks for an article you choose!
# c) With which categories is the page tagged?


# functionality
ls("package:WikipediR")

# get page content
content <- page_content("de", "wikipedia", page_name = "Brandenburger_Tor", as_wikitext = TRUE)
str(content)
content$parse$wikitext %>% unlist %>% cat

# get page links (careful: max 500 links)
links <- page_links("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500, namespaces = 0)
lapply(links[[1]]$links, "[", 2) %>% unlist

# get page backlinks (links referring to a given web resource; careful: max 500 backlinks)
backlinks <- page_backlinks("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500, namespaces = 0)
unlist(backlinks) %>%  .[names(.) == "title"] %>% as.character

# get external links
extlinks <- page_external_links("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500)
extlinks[[1]]$extlinks

# metadata on article
metadata <- page_info("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE) 
metadata[[1]] %>% t() %>% as.data.frame

# which categories in page
cats <- categories_in_page("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE)
cats[[1]]$categories


# 2. familiarize yourself with the OpenWeatherMap API!
browseURL("http://openweathermap.org/current")

# a) sign up for the API at the address below and obtain an API key!
browseURL("http://openweathermap.org/api")
# b) make a call to the API to find out the current weather conditions in Washington!

load("/Users/simonmunzert/rkeys.RDa")
apikey <- paste0("&appid=", openweathermap)
endpoint <- "http://api.openweathermap.org/data/2.5/find?"
city <- "Washington"
metric <- "&units=metric"
url <- paste0(endpoint, "q=", city, metric, apikey)
weather_res <- GET(url)
res_list <- content(weather_res, as =  "parsed")
res_list <- content(weather_res, as =  "text")  %>% jsonlite::fromJSON(flatten = TRUE)
res_list$list


# 3. familiarize yourself with the NY Times API!
browseURL("http://developer.nytimes.com/article_search_v2.json#/README")

# a) sign up for the API at the address below and obtain an API key!
browseURL("http://developer.nytimes.com/")

# b) use the rtimes package to retrieve the number of articles each that were published in the NY Times last year and that the following politicians: Nancy Pelosi, Mitch McConnell, John McCain, and Alexandra Ocasio-Cortez!
browseURL("https://cran.r-project.org/web/packages/rtimes/vignettes/rtimes_vignette.html")

# use API
library(rtimes)
load("/Users/simonmunzert/Munzert Dropbox/Simon Munzert/rkeys.RDa")
Sys.setenv(NYTIMES_AS_KEY = nytimes_apikey)

terms <- c("John McCain", "Nancy Pelosi", "Bernie Sanders", "Al Franken", "Marco Rubio", "Paul Ryan", "Elizabeth Warren", "Mitch McConnell", "Tim Kaine", "Dianne Feinstein")


nytimes_hits <- numeric()
for(i in seq_along(terms)) {
  nytimes_hits[i] <-  as_search(q = terms[i], begin_date = "20180101", end_date = '20180930')$meta$hits
  Sys.sleep(runif(1, 1, 2))
}
nytimes_hits_df <- data.frame(name = terms, nytimes_hits, stringsAsFactors = FALSE)
head(nytimes_hits_df)



## workflow ---------------------------------------

# go to the following webpage.
url <- "http://www.cses.org/datacenter/module4/module4.htm"
browseURL(url)

# the following piece of code identifies all links to resources on the webpage and selects the subset of links that refers to the survey questionnaire PDFs.
library(rvest)
page_links <- read_html(url) %>% html_nodes("a") %>% html_attr("href")
survey_pdfs <- str_subset(page_links, "/survey")

# a) set up folder data/cses-pdfs.
dir.create("data/cses-pdfs", recursive = TRUE)

# b) download a sample of 10 of the survey questionnaire PDFs into that folder using a for loop and the download.file() function.
baseurl <- "http://www.cses.org"
for (i in 1:10) {
  filename <- basename(survey_pdfs[i])
  if(!file.exists(paste0("data/cses-pdfs/", filename))){
    download.file(paste0(baseurl, survey_pdfs[i]), destfile = paste0("data/cses-pdfs/", filename))
    Sys.sleep(runif(1, 0, 1))
  }
}

# c) check if the number of files in the folder corresponds with the number of downloads and list the names of the files.
length(list.files("data/cses-pdfs"))
list.files("data/cses-pdfs")

# d) inspect the files. which is the largest one?
file.info(dir("data/cses-pdfs", full.names = TRUE)) %>% View()

# e) zip all files into one zip file.
zip("data/cses-pdfs/cses-mod4-questionnaires.zip", dir("data/cses-pdfs", full.names = TRUE))
