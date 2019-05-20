### -----------------------------
### simon munzert
### workflow and good practice
### -----------------------------

## peparations -------------------

source("packages.r")



## how to create functions ------------

# R is a functional programming lanugage, i.e. it provides many tools for the creation and manipulation of functions
# you can do virtually anything with functions: assign them to variables, store them in lists, pass them as arguments to other functions, ...
# very helpful in obeying the "don't repeat yourself" a.k.a. DRY principle
# on functions in R:
# objects of their own
# you can work with them as with any other type of object
# when you print a function in R, all these components are shown

# function that returns the mean of a vector
my_mean <- function(my_vector) {
  mean <- sum(my_vector)/length(my_vector) 
  mean
}
my_mean(c(1, 2, 3))
my_mean


# another function that finds the remainder after division ("modulo operation)
remainder <- function(num = 10, divisor = 4) {
  remain <- num %% divisor
  remain
}
remainder()
args(remainder)

# implement conditions
has_name <- function(x) {
  nms <- names(x)
  if (is.null(nms)) {
    rep(FALSE, length(x))
  } else {
    !is.na(nms) & nms != ""
  }
}
has_name(c(1, 2, 3))
has_name(mtcars)


# stopifnot() to ensure truth of R expressions
wt_mean <- function(x, w, na.rm = FALSE) {
  stopifnot(is.logical(na.rm), length(na.rm) == 1)
  stopifnot(length(x) == length(w))
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(x)
}
wt_mean(1:6, 5:1, na.rm = FALSE)

# stop with better error messages
wt_mean <- function(x, w, na.rm = FALSE) {
  stopifnot(is.logical(na.rm), length(na.rm) == 1)
  if(length(x) != length(w)) {
    stop("The length of x, the numeric input vector, is not equal to the length of w, the weights vector.")
  }
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(x)
}
wt_mean(1:6, 5:1, na.rm = FALSE)


## condition handling --------------

# sometimes, errors are expected, and you want to handle them automatically, e.g.
# model fails to converge
# download of files fails
# stack processing of lists

# most useful functions: try() and tryCatch()

f1 <- function(x) { 
  log(x) 
  10 
} 
f1("x")

# ignore error
f1 <- function(x) { 
  try(log(x))
  10 
} 
f1("x")

# suppress error message
f1 <- function(x) { 
  try(log(x), silent = TRUE)
  10 
} 
f1("x")

# pass block of code to try()
try({ 
  a <- 1 
  b <- "x" 
  a + b 
})

# capture the output of try()
success <- try(1 + 2) 
failure <- try("a" + "b") 
class(success)
class(failure) 

# use try() when applying a function to multiple elements in a list
elements <- list(1:10, c(-1, 10), c(T, F), letters) 
results <- lapply(elements, log)

results <- lapply(elements, function(x) try(log(x)))

# test for "try-error" class
is.error <- function(x) inherits(x, "try-error") 
succeeded <- !sapply(results, is.error)

str(results[succeeded])
str(elements[!succeeded])




## Scheduling scraping tasks on Windows -------

browseURL("https://cran.r-project.org/web/packages/taskscheduleR/vignettes/taskscheduleR.html")


## Scheduling scraping tasks on a Mac ---------

browseURL("https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/ScheduledJobs.html")

# 1. create script (e.g., "spiegel_scraper.R")
# 2. add "#!/usr/local/bin/Rscript" to the top of the script
# 3. create plist file
# 4. load plist file into launchd scheduler and start it (via Terminal):
system("launchctl load ~/Library/LaunchAgents/spiegelheadlines.plist")
system("launchctl start spiegelheadlines")
system("launchctl list")

# 5. stop and unload it when desired
system("launchctl stop spiegelheadlines")
system("launchctl unload ~/Library/LaunchAgents/spiegelheadlines.plist")



## EXERCISE -------


# go to the following webpage.
url <- "http://www.cses.org/datacenter/module4/module4.htm"
browseURL(url)

# the following piece of code identifies all links to resources on the webpage and selects the subset of links that refers to the survey questionnaire PDFs.
library(rvest)
page_links <- read_html(url) %>% html_nodes("a") %>% html_attr("href")
survey_pdfs <- str_subset(page_links, "/survey")

# a) set up folder data/cses-pdfs.

# b) download a sample of 10 of the survey questionnaire PDFs into that folder using a for loop and the download.file() function.

# c) check if the number of files in the folder corresponds with the number of downloads and list the names of the files.

# d) inspect the files. which is the largest one?

# e) zip all files into one zip file.
