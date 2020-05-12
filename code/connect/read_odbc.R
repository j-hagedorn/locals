# read_odbc.R

library(DBI); library(odbc);library(dbplyr);library(tidyverse);library(lubridate)

# Geographic reference data stored as .rda

load("data/fips_state.rda"); load("data/fips_county.rda")
load("data/fips_tract.rda"); load("data/fips_blockgroup.rda")

# Join all geographies

fips <-
  fips_state %>%
  left_join(fips_county,by = c("state_id")) %>%
  left_join(fips_tract,by = c("state_id","county_id")) %>%
  left_join(fips_blockgroup,by = c("state_id","county_id","tract_id"))

rm(list = c("fips_state","fips_county","fips_tract","fips_blockgroup"))

# Connect to db

locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

# Create local references to tables ####

tracts_db <- tbl(locals_db, "tracts")
counties_db <- tbl(locals_db, "counties")
covid_db <- tbl(locals_db, "covid")

tracts_db %>%
  group_by(dataset) %>%
  summarize(n = n())

