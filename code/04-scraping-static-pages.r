### -----------------------------
## simon munzert
## scraping static pages
### -----------------------------

source("packages.r")


## basic workflow of scraping with rvest  ----------

# see also: https://github.com/hadley/rvest
# convenient package to scrape information from web pages
# builds on other packages, such as xml2 and httr
# provides very intuitive functions to import and process webpages

# 1. specify URL
url <- "https://en.wikipedia.org/wiki/List_of_tallest_buildings_in_Switzerland"
browseURL(url)

# 2. download static HTML behind the URL and parse it
url_parsed <- read_html(url)

# 3. extract specific nodes with XPath
nodes <- html_nodes(url_parsed, xpath = '//td[2]')

# 4. extract content from nodes
article_links <- html_text(nodes)
article_links %>% str_replace("\\n", "")



## extract data from tables --------------

## HTML tables 
  # ... are a special case for scraping because they are already very close to the data structure you want to build up in R
  # ... come with standard tags and are usually easily identifiable

## scraping HTML tables with rvest
url <- "https://en.wikipedia.org/wiki/List_of_tallest_buildings_in_Switzerland"
url_parsed <- read_html(url)
tables <- html_table(url_parsed, header = TRUE, fill = TRUE)
tab <- tables[[1]]
head(tab)

## another example
url_p <- read_html("https://en.wikipedia.org/wiki/List_of_MPs_elected_in_the_United_Kingdom_general_election,_1992")
tables <- html_table(url_p, header = TRUE, fill = TRUE)
mps <- tables[[4]]
head(mps)
names(mps) <- c("constituency", "mp", "party")
mps <- mps[2:nrow(mps),]
mps <- filter(mps, !str_detect(constituency, fixed("[edit]")))

table(mps$party, str_detect(mps$mp, "^Sir ")) # how many "Sirs" per party?

## note: HTML tables can get quite complex. there are more flexible solutions than html_table() on the market (e.g., package "htmltab") 



### working with SelectorGadget ----------

# to learn about it, visit
vignette("selectorgadget")

# to install it, visit
browseURL("http://selectorgadget.com/")
# and follow the advice below: "drag this link to your bookmark bar: >>SelectorGadget>> (updated August 7, 2013)"

## SelectorGadget is magic. Proof:

url <- "https://www.washingtonpost.com"
url <- "http://www.spiegel.de/schlagzeilen/"
browseURL(url)

url_parsed <- read_html(url)

xpath <- '//*[contains(concat( " ", @class, " " ), concat( " ", "text-align-inherit", " " ))]'
xpath <- '//*[contains(concat( " ", @class, " " ), concat( " ", "schlagzeilen-headline", " " ))]'

xpath <- '//*[(@id = "main-content")]//*[contains(concat( " ", @class, " " ), concat( " ", "text-align-inherit", " " ))]'
headings_nodes <- html_nodes(url_parsed, xpath = xpath)

headings <- html_text(headings_nodes)
headings <- str_subset(headings, "^[:alnum:]")
head(headings)
length(headings)



## EXERCISES ----------


# 1. go to the following website
browseURL("https://www.jstatsoft.org/about/editorialTeam")

# a) which HTML features can be used to describe all names of the editorial team?
# b) write a corresponding XPath expression that targets them, and apply it using rvest!
# c) bonus: try and extract the full lines including the affiliation and count how many of the editors are at a statistics or mathematics department or institution!


# 2. consider the table of tall buildings (300m+) currently under construction from https://en.wikipedia.org/wiki/List_of_tallest_buildings_in_the_world".

# a) scrape it.
# b) how many of those buildings are currently built in China? and in which city are most of the tallest buildings currently built?
# c) what is the sum of heights of all of these buildings?

