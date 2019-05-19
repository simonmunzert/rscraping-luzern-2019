### -----------------------------
### simon munzert
### intro to web scraping with R
### -----------------------------

## preparations -----------------------
source("packages.r")


## inspect the source code in your browser ---------------

browseURL("http://www.biermap24.de/brauereiliste.php") 


# Chrome:
# 1. right click on page
# 2. select "view source"

# Firefox:
# 1. right click on page
# 2. select "view source"

# Microsoft Edge:
# 1. right click on page
# 2. select "view source"

# Safari
# 1. click on "Safari"
# 2. select "Preferences"
# 3. go to "Advanced"
# 4. check "Show Develop menu in menu bar"
# 5. click on "Develop"
# 6. select "show page source"
# 7. alternatively to 5./6., right click on page and select "view source"



## case study 1: map breweries in Germany -------

##  goal
# get list of breweries in Germany
# import list in R
# geolocate breweries
# put them on a map

# set temporary working directory
tempwd <- ("../data/breweriesGermany")
dir.create(tempwd)
setwd(tempwd)

## step 1: fetch list of cities with breweries
url <- "http://www.biermap24.de/brauereiliste.php"
content <- read_html(url)
anchors <- html_nodes(content, xpath = "//tr/td[2]")
cities <- html_text(anchors)
cities
cities <- str_trim(cities)
cities <- cities[str_detect(cities, "^[[:upper:]]+.")]
cities <- cities[6:length(cities)]
length(cities)
length(unique(cities))
sort(table(cities))


## step 2: geocode cities
# get free key for mapquest API at browseURL("https://developer.mapquest.com/")
load("/Users/simonmunzert/rkeys.RDa") # import API key (or paste it here in openstreetmap object)

pos <- data.frame(lon = NA, lat = NA)
if (!file.exists("geocodes_cities.RData")){
  for (i in 1:length(unique_cities)) {
    pos[i,] <- try(nominatim::osm_search(unique_cities[i], country_codes = "de", key = openstreetmap) %>% dplyr::select(lon, lat))
  }
  pos$city <- unique_cities
  pos <- filter(pos, !str_detect(lon, "Error"))
  pos$lon <- as.numeric(pos$lon)
  pos$lat <- as.numeric(pos$lat)
  save(pos, file="geocodes_cities.RData")
} else {
  load("geocodes_cities.RData")
}
head(pos)


## step 3: plot breweries of Germany
pos <- filter(pos, lon >= 6, lon <= 15, lat >= 47, lat <= 55)
worldmap <- rnaturalearth::ne_countries(scale = 'medium', type = 'map_units', returnclass = 'sf')
germany <- worldmap[worldmap$name == 'Germany',]
ggplot() + geom_sf(data = germany) + theme_bw() + geom_point(aes(lon,lat), data = pos, size = .5, color = "red") 


## return to base working drive
setwd("../../code")


## case study 2: build a network of statisticians -------

## goals

# gather list of statisticians
# fetch Wikipedia entries
# identify links
# construct connectivity matrix
# visualize network


# set temporary working directory
tempwd <- ("../data/wikipediaStatisticians")
dir.create(tempwd)
setwd(tempwd)


## step 1: inspect page
url <- "https://en.wikipedia.org/wiki/List_of_statisticians"
browseURL(url)


## step 2: retrieve links
html <- read_html(url)
anchors <- html_nodes(html, xpath = "//ul/li/a[1]")
links <- html_attr(anchors, "href")

links <- links[!is.na(links)]
links_iffer <-
  seq_along(links) >=
  seq_along(links)[str_detect(links, "Odd_Aalen")] &
  seq_along(links) <=
  seq_along(links)[str_detect(links, "George_Kingsley_Zipf")] &
  str_detect(links, "/wiki/")
links_index <- seq_along(links)[links_iffer]
links <- links[links_iffer]
length(links)


##  step 3: extract names
names <- links %>% basename %>% sapply(., URLdecode)  %>% str_replace_all("_", " ") %>% str_replace_all(" \\(.*\\)", "") %>% str_trim


## step 4: fetch personal wiki pages
baseurl <- "http://en.wikipedia.org"
HTML <- list()
Fname <- str_c(basename(links), ".html")
URL <- str_c(baseurl, links)
# loop
for ( i in seq_along(links) ){
  # url
  url <- URL[i]
  # fname
  fname <- Fname[i]
  # download
  if ( !file.exists(fname) ) download.file(url, fname)
  # read in files
  HTML[[i]] <- read_html(fname)
}


## step 5: identify links between statisticians
# loop preparation
connections <- data.frame(from=NULL, to=NULL)
# loop
for (i in seq_along(HTML)) {
  pslinks <- html_attr(
    html_nodes(HTML[[i]], xpath="//p//a"), # note: only look for links in p sections; otherwise too many links collected
    "href")
  links_in_pslinks <- seq_along(links)[links %in% pslinks]
  links_in_pslinks <- links_in_pslinks[links_in_pslinks!=i]
  connections <- rbind(
    connections,
    data.frame(
      from=rep(i-1, length(links_in_pslinks)), # -1 for zero-indexing
      to=links_in_pslinks-1 # here too
    )
  )
}

# results
names(connections) <- c("from", "to")
head(connections)

# make symmetrical
connections <- rbind(
  connections,
  data.frame(from=connections$to,
             to=connections$from)
)
connections <- connections[!duplicated(connections),]


## step 6: visualize connections
connections$value <- 1
nodesDF <- data.frame(name = names, group = 1)

network_out <- forceNetwork(Links = connections, Nodes = nodesDF, Source = "from", Target = "to", Value = "value", NodeID = "name", Group = "group", zoom = TRUE, fontSize = 14, opacityNoHover = 3)

saveNetwork(network_out, file = 'connections.html')
browseURL("connections.html")


## step 7: identify top nodes in data frame
nodesDF$id <- as.numeric(rownames(nodesDF)) - 1
connections_df <- merge(connections, nodesDF, by.x = "to", by.y = "id", all = TRUE)
to_count_df <- count(connections_df, name)
arrange(to_count_df, desc(n))
