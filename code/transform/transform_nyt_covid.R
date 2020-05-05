## transform_nyt_covid.R

library(tidyverse)

source("code/fetch/fetch_nyt_covid.R")

us_covid <- us_covid %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d"))

state_covid <- state_covid %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d"))

county_covid <- county_covid %>%
  pivot_longer(
    cols = c(cases, deaths),
    names_to = "var_name"
  ) %>%
  mutate(
    dataset = 'nyt_covid',
    date = as.Date(date, format = "%Y-%m-%d"),
    stat_type = 'n'
  ) %>%
  select(dataset, state, county, fips, date, var_name, value, stat_type)
  
odbc::dbWriteTable(locals_db, "covid", county_covid, append = F)

rm(us_covid); rm(state_covid); rm(county_covid)
