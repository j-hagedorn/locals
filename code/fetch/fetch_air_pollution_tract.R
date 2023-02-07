library(tidyverse)
library(RSocrata)



df <- read.socrata("https://data.cdc.gov/resource/cicv-w9dv.json?statefips=26")

test<-
  df %>% 
  group_by(ctfips) %>% 
  summarise(
    median_ds_o3 = median(as.numeric(ds_o3_pred)),
    n = n()
  ) %>% 
  ungroup() %>% 
  mutate(
    source = 'NEPHT', 
    year = '2016',
    var_short_name = 'Air Pollution',
    var_name = 'Median Daily Pred Particulate Matter & Ozone Levels',
    variable = 'DS_O3_pred',
    value = median_ds_o3,
    tract = ctfips
  ) %>% 
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
             ,test
             ,append = TRUE
)
