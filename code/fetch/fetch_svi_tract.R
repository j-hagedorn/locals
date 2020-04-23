
# https://github.com/yusuzech/r-web-scraping-cheat-sheet/blob/master/README.md#rvest7.9
# https://stanford.edu/~wpmarble/webscraping_tutorial/webscraping_tutorial.pdf

library(tidyverse); library(httr); library(rvest)

url <- "https://svi.cdc.gov/data-and-tools-download.html"

fd <- list(
  btnGo = "Go",
  downloadtype = "data",
  Year = "2018",
  State = "Michigan",
  County = "Census Tracts",
  FileType = "csv"
)

resp <- POST(url, config = set_cookies(my_cookies), body=fd, encode="form", verbose())
content(resp)
headers(resp)
resp


resp <- GET(
  url = url, 
  httr::add_headers(
    Host = "https://svi.cdc.gov/data-and-tools-download.html",
    `User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:58.0) Gecko/20100101 Firefox/58.0",
    Accept = "application/json, text/javascript, */*; q=0.01",
    `Accept-Language` = "en-us,en;q=0.5",
    # Referer = "https://whalewisdom.com/filer/blue-harbour-group-lp",
    `X-Requested-With` = "XMLHttpRequest",
    Connection = "keep-alive"
  ),
  query = fd
)

stop_for_status(resp)
content(resp)


sesh <- html_session(url)
my_session <- html_session(url) # create a session
my_cookies_table <- cookies(my_session) # get the cookies as a table
my_cookies <- my_cookies_table$value %>% setNames(my_cookies_table$name) # save the cookies as a named vector that you can use in your requests
new_session <- html_session(url,set_cookies(my_cookies)) # making requests using the same cookies/session
