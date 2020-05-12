# read_odbc.R

library(DBI); library(odbc);library(dbplyr);library(tidyverse);library(lubridate)

# Geographic reference data stored as .shp



locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

# Create local references to tables ####

tracts_db <- tbl(locals_db, "tracts")
counties_db <- tbl(locals_db, "counties")
covid_db <- tbl(locals_db, "covid")

tracts_db %>%
  group_by(dataset) %>%
  summarize(n = n())

