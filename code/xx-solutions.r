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

# 1. familiarize yourself with the pageviews package! 

# a) what functions does it provide and what do they do?
# b) use the package to fetch page view statistics for the articles about Donald Trump and Hillary Clinton on the English Wikipedia, and plot them against each other in a time series graph!

library(pageviews)
ls("package:pageviews")

trump_views <- article_pageviews(project = "en.wikipedia", article = "Donald Trump", user_type = "user", start = "2016010100", end = "2017051500")
head(trump_views)
save(trump_views, file = "trump_pageviews.RData")
clinton_views <- article_pageviews(project = "en.wikipedia", article = "Hillary Clinton", user_type = "user", start = "2016010100", end = "2017051500")

plot(trump_views$date, trump_views$views, col = "red", type = "l")
lines(clinton_views$date, clinton_views$views, col = "blue")


# 1. familiarize yourself with the OpenWeatherMap API!
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
