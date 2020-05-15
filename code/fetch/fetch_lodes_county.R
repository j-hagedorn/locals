library(tidyverse); library(lehdr); library(tidycensus); library(feather)

lodes_county <- 
  grab_lodes(
    state = unique(
      str_to_lower(
        fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')]
      )
    ), 
    year = 2017,
    lodes_type = "rac", agg_geo = "county"
  )

write_feather(lodes_county,"data/lodes_county.feather")
