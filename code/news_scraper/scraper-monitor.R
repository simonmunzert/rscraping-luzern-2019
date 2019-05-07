#!/usr/local/bin/Rscript
setwd("/Users/s.munzert/Munzert Dropbox/Simon Munzert/vw-news-scraping/code")

library(readr)
library(magrittr)
library(dplyr)
library(lubridate)
library(stringr)

# get data
article_reports <- read_csv("article-reports.csv")
outlets <- read_csv("rss-feeds.csv")$outlet %>% unique

# get date
datetime <- format(as.POSIXct(Sys.time(), tz = Sys.timezone()), usetz = TRUE)  %>% as.character() %>% str_replace_all("[ :]", "-")

# filter today's report
articles_today <- filter(article_reports, date(datetime) == Sys.Date())
outlet_dat <- group_by(articles_today, outlet) %>% summarize(n_access = n(), n_articles = round(sum(n_articles)/n_access))

# build report
outlet_report <- full_join(outlet_dat, data.frame(outlet = outlets, stringsAsFactors = FALSE), by = "outlet") %>% arrange(desc(n_articles))
outlet_report$date <- Sys.Date()

write_csv(outlet_report, "scraping-report.csv", append = TRUE, col_names = FALSE)
write_csv(outlet_report, "/Users/s.munzert/Munzert Dropbox/Simon Munzert/scraping-report.csv", append = TRUE, col_names = FALSE)

