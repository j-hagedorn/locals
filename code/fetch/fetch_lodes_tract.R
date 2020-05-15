library(tidyverse); library(lehdr); library(tidycensus); library(feather)

unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])

lodes_tract <- 
  grab_lodes(
    state = unique(
      str_to_lower(
        fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')]
      )
    ), 
    year = 2017,
    lodes_type = "rac", agg_geo = "tract"
  )

write_feather(lodes_tract,"data/lodes_tract.feather")


