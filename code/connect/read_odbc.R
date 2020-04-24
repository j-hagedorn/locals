# read_odbc.R

library(DBI); library(odbc);library(dbplyr);library(tidyverse);library(lubridate)

locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

# Create local references to SWMBH tables ####

tracts_db <- tbl(locals_db, "tracts")

