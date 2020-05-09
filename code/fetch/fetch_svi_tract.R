
svi_tract <- 
  read_csv("https://data.cdc.gov/api/views/4d8n-kk8a/rows.csv?accessType=DOWNLOAD") %>%
  rename_all(list(~str_to_lower(.))) %>%
  mutate(year = "2018")
 
feather::write_feather(svi_tract,"data/svi_tract.feather")
