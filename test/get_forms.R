
# Submit and download from forms

# https://github.com/yusuzech/r-web-scraping-cheat-sheet/blob/master/README.md#rvest7.9
# https://stanford.edu/~wpmarble/webscraping_tutorial/webscraping_tutorial.pdf

library(tidyverse); library(httr); library(rvest)

url <- "https://svi.cdc.gov/data-and-tools-download.html"
ua <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:75.0) Gecko/20100101 Firefox/75.0"
sesh <- html_session(url) # create a session
cookie_tbl <- cookies(sesh) # get the cookies as a table
my_cookies <- cookie_tbl$value %>% setNames(cookie_tbl$name) # save the cookies as a named vector that you can use in your requests
new_sesh <- html_session(url,set_cookies(my_cookies)) # making requests using the same cookies/session

# pg <- read_html(url)
# tst <- html_nodes(pg, "input")


query <- list(
  downloadtype = "data",
  Year = "2018",
  State = "Michigan",
  County = "Census Tracts",
  FileType = "csv",
  btnGo = "Go"
)

resp <- 
  POST(
    url, 
    config = set_cookies(my_cookies), 
    body = query, 
    encode = "form", 
    user_agent(ua),
    write_disk("svi.csv"),
    verbose()
  )

content(resp)
headers(resp)
resp




stop_for_status(resp)
content(resp)


