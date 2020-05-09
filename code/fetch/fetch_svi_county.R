

svi_county <- 
  read_csv("https://data.cdc.gov/api/views/48va-t53r/rows.csv?accessType=DOWNLOAD") %>%
  rename_all(list(~str_to_lower(.))) %>%
  mutate(year = "2018")

feather::write_feather(svi_county,"data/svi_county.feather")
