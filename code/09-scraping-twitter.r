### -----------------------------
### simon munzert
### social media data
### -----------------------------

## peparations -------------------

source("packages.r")


## about the Twitter APIs

  # two APIs types of interest:
  # REST APIs --> reading/writing/following/etc., "Twitter remote control"
browseURL("https://dev.twitter.com/rest/public/search")
  # "The Twitter Search API searches against a sampling of recent Tweets published in the past 7 days."
  # Streaming APIs --> low latency access to 1% of global stream - public, user and site streams
browseURL("https://dev.twitter.com/streaming/overview")
browseURL("https://dev.twitter.com/streaming/overview/request-parameters")

## R packages that connect to Twitter API

  # twitteR: connects to REST API; weird design decisions regarding data format
  # streamR: connects to Streaming API; works very reliably, connection setup a bit difficult
  # rtweet: connects to both REST and Streaming API, nice data formats, still under active development


## authentication with rtweet ----------------

# how to register at Twitter as developer, obtain and use access tokens
browseURL("https://mkearney.github.io/rtweet/articles/auth.html")

TwitterToR_twitterkey <- "uBoAsdknehdiosd8nkhk234aTIApT"  # <--- add your Twitter key here!
TwitterToR_twittersecret <- "myhHWkdjUhgaljsekh4ksfg8sK8tthJFl9fHJKLAnehkxi4nlYlQM" # <--- add your Twitter secret here!
TwitterToR_accesstoken <- "124573244-6Nd4dklsfj483Jzfeskg9GJCtD"  # <--- add your Twitter access token here!
TwitterToR_accesssecret <- "myhHWkkd872kHnk32k4HkfjKLAnehkxi4nlYlQM" # <--- add your Twitter secret here!

save(TwitterToR_twitterkey,
     TwitterToR_twittersecret,
     TwitterToR_accesstoken,
     TwitterToR_accesssecret,
     file = paste0(normalizePath("~/"),"/twitterkeys.RDa")) # <--- this is where your keys are locally stored!

## name assigned to created app
appname <- "TwitterToR" # <--- add your Twitter App name here!

## api key (example below is not a real key)
load("/Users/simonmunzert/twitterkeys.RDa") # <--- adapt path here; see above!

## register app
twitter_token <- create_token(
  app = appname,
  consumer_key = TwitterToR_twitterkey,
  consumer_secret = TwitterToR_twittersecret,
  access_token = TwitterToR_accesstoken,
  access_secret = TwitterToR_accesssecret,
  set_renv = FALSE)

## check if everything worked
rt <- search_tweets("merkel", n = 200, token = twitter_token)
View(rt)


## search Tweets with the rtweet package --------------

# some advice for search:
browseURL("https://developer.twitter.com/en/docs/tweets/search/guides/standard-operators")

merkel <- search_tweets("merkel", n = 1000, include_rts = FALSE, lang = "de")

trump_bad <- search_tweets(URLencode("trump :("), n = 100, include_rts = FALSE, lang = "en", token = twitter_token)
trump_good <- search_tweets(URLencode("trump :)"), n = 100, include_rts = FALSE, lang = "en", token = twitter_token)
trump_images <- search_tweets(URLencode("trump filter:images"), n = 100, include_rts = FALSE, lang = "en", token = twitter_token)


# check rate limits
rate_limits(token = twitter_token) %>% View()


## streaming Tweets with the rtweet package -----------------

# set keywords used to filter tweets
q <- paste0("merkel,trump,macron")

# parse directly into data frame
twitter_stream <- stream_tweets(q = q, timeout = 30, token = twitter_token)

# set up directory and JSON dump
rtweet.folder <- "data/rtweet-data"
dir.create(rtweet.folder)
streamname <- "politicians"
filename <- file.path(rtweet.folder, paste0(streamname, "_", format(Sys.time(), "%F-%H-%M-%S"), ".json"))

# create file with stream's meta data
streamtime <- format(Sys.time(), "%F-%H-%M-%S")
metadata <- paste0(
  "q = ", q, "\n",
  "streamtime = ", streamtime, "\n",
  "filename = ", filename)
metafile <- gsub(".json$", ".txt", filename)
cat(metadata, file = metafile)

# sink stream into JSON file
stream_tweets(q = q, parse = FALSE,
              timeout = 30,
              file_name = filename,
              #language = "de",
              token = twitter_token)

# parse from json file
rt <- parse_stream(filename)

# inspect tweets data
names(rt)
head(rt)

# inspect users data
users_data(rt) %>% head()
users_data(rt) %>% names()


## mining twitter accounts with the rtweet package ------

user_df <- lookup_users("RDataCollection")
names(user_df)
user_timeline_df <- get_timeline("RDataCollection")
names(user_timeline_df)
user_favorites_df <- get_favorites("RDataCollection")
names(user_favorites_df)
followers <- get_followers("RDataCollection")
friends <- get_friends("RDataCollection")



