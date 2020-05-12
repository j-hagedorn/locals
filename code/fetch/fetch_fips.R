## fetch_fips.R

library(tidyverse); library(tidycensus);library(sf)
options(tigris_use_cache = TRUE)

---

# Download block group geometries

fips_blockgroup <- tibble()

for (i in unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])) {
  
  sf <-
    get_acs(
      geography = "block group", variables = "B00001_001",
      cache_table = T, state = i, geometry = T, keep_geo_vars = T
    )
  fips_blockgroup <- bind_rows(fips_blockgroup,sf)
  rm(sf);rm(i)
  
}  

fips_blockgroup <-
  fips_blockgroup %>%
  rename_all(list(~str_to_lower(.))) %>%
  rename_at(vars(any_of(c('statefp','countyfp'))),list(~str_replace(.,"fp$","_id"))) %>%
  rename_at(vars(any_of(c('tractce','blkgrpce'))),list(~str_replace(.,"ce$","_id"))) %>%
  rename(pop = estimate, name = name.y) %>%
  select(-affgeoid,-name.x,-variable,-lsad) %>%
  # Convert area to square miles
  mutate(sqmi = aland / 2589988) %>%
  # Label block-specific vars with 'blkgrp_' prefix
  rename_at(vars(!ends_with("_id")),list(~paste0(.,"_blkgrp"))) 

save(fips_blockgroup,file="data/fips_blockgroup.rda")

---
  
# Download tract geometries

fips_tract <- tibble()

for (i in unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])) {
  
  sf <-
    get_acs(
      geography = "tract", variables = "B00001_001",
      cache_table = T, state = i, geometry = T, keep_geo_vars = T
    )
  fips_tract <- bind_rows(fips_tract,sf)
  rm(sf);rm(i)
  
}  

fips_tract <-
  fips_tract %>%
  rename_all(list(~str_to_lower(.))) %>%
  rename_at(vars(any_of(c('statefp','countyfp'))),list(~str_replace(.,"fp$","_id"))) %>%
  rename_at(vars(any_of(c('tractce','blkgrpce'))),list(~str_replace(.,"ce$","_id"))) %>%
  rename(pop = estimate, name = name.y) %>%
  select(-affgeoid,-name.x,-variable,-lsad) %>%
  # Convert area to square miles
  mutate(sqmi = aland / 2589988) %>%
  # Label tract-specific vars with '_tract' suffix
  rename_at(vars(!ends_with("_id")),list(~paste0(.,"_tract"))) 

save(fips_tract,file = "data/fips_tract.rda")

# Download county geometries

fips_county <- tibble()

for (i in unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])) {
  
  sf <-
    get_acs(
      geography = "county", variables = "B00001_001",
      cache_table = T, state = i, geometry = T, keep_geo_vars = T
    )
  fips_county <- bind_rows(fips_county,sf)
  rm(sf);rm(i)
  
}  

fips_county <-
  fips_county %>%
  rename_all(list(~str_to_lower(.))) %>%
  rename_at(vars(any_of(c('statefp','countyfp'))),list(~str_replace(.,"fp$","_id"))) %>%
  rename_at(vars(any_of(c('tractce','blkgrpce'))),list(~str_replace(.,"ce$","_id"))) %>%
  rename(pop = estimate, name = name.y) %>%
  select(-affgeoid,-countyns,-name.x,-variable,-lsad) %>%
  # Convert area to square miles
  mutate(sqmi = aland / 2589988) %>%
  # Label tract-specific vars with '_tract' suffix
  rename_at(vars(!ends_with("_id")),list(~paste0(.,"_county"))) 

save(fips_county,file = "data/fips_county.rda")

# Download county geometries

fips_state <- tibble()

for (i in unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])) {
  
  sf <-
    get_acs(
      geography = "state", variables = "B00001_001",
      cache_table = T, state = i, geometry = T, keep_geo_vars = T
    )
  fips_state <- bind_rows(fips_state,sf)
  rm(sf);rm(i)
  
}  

fips_state <-
  fips_state %>%
  rename_all(list(~str_to_lower(.))) %>%
  rename_at(vars(any_of(c('statefp','countyfp'))),list(~str_replace(.,"fp$","_id"))) %>%
  rename_at(vars(any_of(c('tractce','blkgrpce'))),list(~str_replace(.,"ce$","_id"))) %>%
  rename(pop = estimate, name = name.y) %>%
  select(-affgeoid,-statens,-name.x,-variable,-stusps,-lsad) %>%
  # Convert area to square miles
  mutate(sqmi = aland / 2589988) %>%
  # Label tract-specific vars with '_tract' suffix
  rename_at(vars(!ends_with("_id")),list(~paste0(.,"_state"))) 

save(fips_state,file = "data/fips_state.rda")

# save(fips,file = "data/fips.rda")

# # Convert to shapefiles
# 
# fips_county_shape <-
#   fips_county %>%
#   st_as_sf(sf_column_name = "geometry_county")
# 
# fips_tract_shape <- 
#   fips_tract %>%
#   st_as_sf(sf_column_name = "geometry_tract") 
# 
# fips_block_shape <-
#   fips_blockgroup %>%
#   st_as_sf(sf_column_name = "geometry_blkgrp")



