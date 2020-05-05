## fetch_nyt_covid.R

library(httr)

us_covid <- read.csv(
  url("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv"))

state_covid <- read.csv(
  url("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv"))
  
county_covid <- read.csv(
  url("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv"))


