library(tidyverse)
library(lubridate)
library(DBI)

evictions_source<-source("code/fetch/fetch_evictions_tract.R") 
  
evictions = 
  evictions_source$value %>% 
  filter(state == 'Michigan') %>% 
  group_by(fips) %>% 
  filter(year == max(year)) %>% 
  ungroup() %>% 
  mutate(judgement_rate = coalesce(judgement_rate,0),
         source = 'eviction_labs',
         tract = fips,
         var_short_name = 'Eviction Rate',
         value = coalesce(judgement_rate,0),
         var_name = "Ratio of Evictions to Rental Housing Units",
         variable = 'judgement_rate') %>% 
  select(source,year,tract,var_short_name,value,var_name,variable) %>% 
  mutate_all(as.character)


# Push data to the database

con_tbd_locals <- 
  DBI::dbConnect(
    odbc::odbc(),
    Driver = "SQL Server",
    Server = Sys.getenv("tbd_server_address"),
    Database = "locals",
    UID      = Sys.getenv("tbd_server_uid"),
    PWD      = Sys.getenv("tbd_server_pw"),
    Port     = 1433
  )


dbWriteTable(con_tbd_locals
             ,'tracts'
            # ,evictions,overwrite = TRUE
             )

rm(evictions_source,evictions,con_tbd_locals)