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

# Convert to shapefiles

fips_county_shape <-
  fips_county %>%
  st_as_sf(sf_column_name = "geometry_county")
  
fips_tract_shape <- 
  fips_tract %>%
  st_as_sf(sf_column_name = "geometry_tract") 

fips_block_shape <-
  fips_blockgroup %>%
  st_as_sf(sf_column_name = "geometry_blkgrp")

# Save as .shp, since SQL can't hold nested lists  
st_write(fips_block_shape,"data/fips_block_shape.shp",append = F)
blk_shp_cols <- colnames(fips_block_shape)
fips_block_shape <- sf::read_sf("data/fips_block_shape.shp")
colnames(fips_block_shape) <- blk_shp_cols # Replace colnames b/c ESRI files truncate

# Save as .shp, since SQL can't hold nested lists  
st_write(fips_tract_shape,"data/fips_tract_shape.shp",append = F)
trct_shp_cols <- colnames(fips_tract_shape)
tst <- sf::read_sf("data/fips_tract_shape.shp")
colnames(fips_tract_shape) <- trct_shp_cols # Replace colnames b/c ESRI files truncate


  


# Save as .shp, since SQL can't hold nested lists  
sf::st_write(fips_county_shape,"data/fips_county_shape.shp",append=F)
fips_county_shape <- sf::read_sf("data/fips_county_shape.shp")

---

# Join tract and block groups

tst <-
  fips_county %>%
  left_join(fips_blockgroup,by = c("state_id","county_id","tract_id"))