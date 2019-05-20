### -----------------------------
### simon munzert
### workflow and good practice
### -----------------------------

## peparations -------------------

source("packages.r")


## Staying friendly on the web ------

# work with informative header fields
# don't bombard server
# respect robots.txt

# add User-Agent string
url <- "http://spiegel.de/schlagzeilen"
browseURL("http://www.whoishostingthis.com/tools/user-agent/")
uastring <- "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36"
session <- html_session(url, user_agent(uastring))

# add header fields with rvest + httr
session <- html_session(url, add_headers(From = "my@email.com", `User-Agent` = "R Scraper"))
headlines <- session %>% html_nodes(".schlagzeilen-headline") %>%  html_text()


# don't bombard server
for (i in 1:length(urls_list)) {
  if (!file.exists(paste0(folder, names[i]))) {
    download.file(urls_list[i], destfile = paste0(folder, names[i]))
    Sys.sleep(runif(1, 0, 1))
  }
}

# respect robots.txt
browseURL("https://www.google.com/robots.txt")
browseURL("http://www.nytimes.com/robots.txt")

library(robotstxt)
# more info see here: https://cran.r-project.org/web/packages/robotstxt/vignettes/using_robotstxt.html

paths_allowed("/", "http://google.com/", bot = "*")
paths_allowed("/", "https://facebook.com/", bot = "*")

paths_allowed("/imgres", "http://google.com/", bot = "*")
paths_allowed("/imgres", "http://google.com/", bot = "Twitterbot")


r_text <- get_robotstxt("https://www.google.com/")
r_parsed <- parse_robotstxt(r_text)
names(r_parsed)
table(r_parsed$permissions$useragent, r_parsed$permissions$field)


