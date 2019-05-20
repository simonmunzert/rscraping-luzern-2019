### -----------------------------
### simon munzert
### tapping apis
### -----------------------------

## peparations -------------------

source("packages.r")

## ready-made R bindings to web APIs ---------

## overview
browseURL("http://ropensci.org/")
browseURL("https://github.com/ropensci/opendata")
browseURL("https://cran.r-project.org/web/views/WebTechnologies.html")


## some examples ---------

## example: IP API

# API documentation
browseURL("http://ip-api.com/")

# ipapi package
#devtools::install_github("hrbrmstr/ipapi")
library(ipapi)

# function call
ip_df <- geolocate(c(NA, "", "10.0.1.1", "72.33.67.89", "www.nytimes.com", "search.twitter.com"), .progress = TRUE)
View(ip_df)


## example: Wikipedia REST API

# documentation
browseURL("https://wikimedia.org/api/rest_v1/#/Pageviews%20data")

## the pageviews package

# functionality
ls("package:pageviews")

# get pageviews
trump_views <- article_pageviews(project = "en.wikipedia", article = "Donald Trump", user_type = "user", start = "2015070100", end = "2017050100")
head(trump_views)
clinton_views <- article_pageviews(project = "en.wikipedia", article = "Hillary Clinton", user_type = "user", start = "2015070100", end = "2017050100")

plot(ymd(trump_views$date), trump_views$views, col = "red", type = "l")
lines(ymd(clinton_views$date), clinton_views$views, col = "blue")

# interactive tool available at
browseURL("https://tools.wmflabs.org/pageviews/")



## accessing APIs from scratch ---------

# most modern APIs use HTTP (HyperText Transfer Protocol) for communication and data transfer between server and client
# R package httr as a good-to-use HTTP client interface
# most web data APIs return data in JSON or XML format
# R packages jsonlite and xml2 good to process JSON or XML-style data

# if you want to tap an existing API, you have to
  # figure out how it works (what requests/actions are possible, what endpoints exist, what )
  # (register to use the API)
  # formulate queries to the API from within R
  # process the incoming data


## example: back to the IP API

# API documentation
browseURL("http://ip-api.com/docs/")

# manual API call, XML data
url <- "http://ip-api.com/xml/"
ip_parsed <- xml2::read_xml(url)
ip_df <- as_list(ip_parsed) %>% as.data.frame(stringsAsFactors = FALSE)
var_names <- xml_nodes(ip_parsed, xpath = "//query/child::*") %>% xml_name()
names(ip_df) <- var_names
ip_df

# manual API call, JSON data
url <- "http://ip-api.com/json"
ip_parsed <- jsonlite::fromJSON(url)
as.data.frame(ip_parsed, stringsAsFactors = FALSE)

# modify call
fromJSON("http://ip-api.com/json/72.33.67.89") %>% as.data.frame(stringsAsFactors = FALSE)
fromJSON("http://ip-api.com/json/www.nytimes.com") %>% as.data.frame(stringsAsFactors = FALSE)

# build function
ipapi_grabber <- function(ip = "") {
  dat <- fromJSON(paste0("http://ip-api.com/json/", ip)) %>% as.data.frame(stringsAsFactors = FALSE)
  dat
}
ipapi_grabber("193.17.243.1")



## EXERCISES ----------

# 1. familiarize yourself with the WikipediR package! 
browseURL("https://cran.r-project.org/web/packages/WikipediR/vignettes/WikipediR.html")

# a) what functions does it provide and what do they do?
# b) use the package to get content, links, and backlinks for an article you choose!
# c) With which categories is the page tagged?

# 2. familiarize yourself with the Openweathermap API!
browseURL("http://openweathermap.org/current")

# a) sign up for the API at the address below and obtain an API key!
browseURL("http://openweathermap.org/api")
# b) make a call to the API to find out the current weather conditions in Washington!

# 3. familiarize yourself with the NY Times API!
browseURL("http://developer.nytimes.com/article_search_v2.json#/README")

# a) sign up for the API at the address below and obtain an API key!
browseURL("http://developer.nytimes.com/")

# b) use the rtimes package to retrieve the number of articles each that were published in the NY Times last year and that the following politicians: Nancy Pelosi, Mitch McConnell, John McCain, and Alexandra Ocasio-Cortez!
browseURL("https://cran.r-project.org/web/packages/rtimes/vignettes/rtimes_vignette.html")



