#!/usr/local/bin/Rscript
setwd("/Users/simonmunzert/Munzert Dropbox/Simon Munzert/vw-news-scraping/code")

library(readr)
library(magrittr)

source("scraper-news-functions.R")

rss_feeds <- read_csv("rss-feeds.csv")

outlets <- rss_feeds$outlet[rss_feeds$feedburner == FALSE] %>% unique()
outlets_feedburner <- rss_feeds$outlet[rss_feeds$feedburner == TRUE] %>% unique()

for(i in outlets_feedburner){
  try(news_rss_scraper(outlet = i))
  try(news_articles_scraper(outlet = i, feedburner = TRUE))
  try(news_frontpage_scraper(outlet = i))
}

for(i in outlets){
  try(news_rss_scraper(outlet = i))
  try(news_articles_scraper(outlet = i))
  try(news_frontpage_scraper(outlet = i))
}