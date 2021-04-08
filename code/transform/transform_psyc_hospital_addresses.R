library(tidyverse)
library(readxl)
library(DBI)
library(odbc)
library(ggmap)





#============================#
# Formatting NPI Data  ====
#============================#

pysc_impatient<-
  bind_rows(npi,cms) %>%
  # Removing duplicates based on matching addresses 
  group_by(address) %>%
  mutate(row_n = row_number()) %>%
  ungroup() %>%
  filter(row_n == 1) %>%
  # Removing duplicates based on matching coordinates
  group_by(lat,lon) %>%
  mutate(row_n = row_number()) %>%
  ungroup() %>%
  filter(row_n == 1) %>%
  # Removing duplicates based on matching block group IDs
  group_by(block_id) %>%
  mutate(row_n = row_number()) %>%
  ungroup() %>%
  filter(row_n == 1) %>%
  select(-row_n)
  

#=============================================#
# Appending to Locals Addresses Dataset  ====
#=============================================#

# Database connections
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

# Writing updated or new variables to data base 
odbc::dbWriteTable(locals_db, 'addresses', pysc_impatient, append = T)





