## transform_nyt_covid.R

library(tidyverse)

source("code/fetch/fetch_nyt_covid.R")

us_covid <- us_covid %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d"))

state_covid <- state_covid %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d"))

county_covid <- county_covid %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d"))
