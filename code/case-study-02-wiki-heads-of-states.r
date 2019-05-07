### -----------------------------------------------------
### Case Study: Getting data on state leaders from Wikipedia
### Simon Munzert
### -----------------------------------------------------


## packages ---------------------

source("packages.r")


# parse page
url <- "https://en.wikipedia.org/wiki/List_of_state_leaders_in_2015"
url_parsed <- read_html(url)

# extract country nodes
country_nodes <- html_nodes(url_parsed, xpath = "//li[./child::b]")
country_text <- html_nodes(country_nodes, xpath = "./*[1]//a[1]")%>% html_text() # does not provide full list, because not all countries are in anchor tags
country_text <- html_nodes(country_nodes, xpath = "./*[1]")%>% html_text() %>% str_trim


# inspect structure of first country node
xml_structure(country_nodes[[1]])

# extract text for first two leaders
leader_1_text <- sapply(country_nodes, function(x) {html_nodes(x, xpath = "./ul/li[1]") %>% html_text()})
leader_1_text[lengths(leader_1_text) == 0] <- ""

leader_2_text <- sapply(country_nodes, function(x) {html_nodes(x, xpath = "./ul/li[2]") %>% html_text()}) 
leader_2_text[lengths(leader_2_text) == 0] <- ""

# extract links for first two leaders
leader_1_link <- sapply(country_nodes, function(x) {html_nodes(x, xpath = "./ul/li[1]/a[1]") %>% html_attr("href")})
leader_1_link[lengths(leader_1_link) == 0] <- ""

leader_2_link <- sapply(country_nodes, function(x) {html_nodes(x, xpath = "./ul/li[2]/a[1]") %>% html_attr("href")})
leader_2_link[lengths(leader_2_link) == 0] <- ""

# compile data frame
dat <- data.frame(country = country_text,
                  leader_1 = unlist(leader_1_text), 
                  leader_1_link = unlist(leader_1_link),
                  leader_2 = unlist(leader_2_text),
                  leader_2_link = unlist(leader_2_link), stringsAsFactors = FALSE)

View(dat)

