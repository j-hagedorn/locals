## fetch_fips.R

library(tidyverse); library(tidycensus);library(sf)
options(tigris_use_cache = TRUE)

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
  st_as_sf(sf_column_name = "geometry") %>%
  # Label block-specific vars with 'blkgrp_' prefix
  rename_at(vars(!ends_with("_id")),list(~paste0(.,"_blkgrp"))) 

# Save as .shp, since SQL can't hold nested lists  
sf::st_write(fips_blockgroup,"data/fips_blockgroup.shp",append=F)

 
  
  
  mapview::mapView(tst, zcol = "estimate", legend = TRUE) 
  
  tst %>%
  ggplot(aes(fill = pop_blkgrp)) + 
  geom_sf(color = NA) + 
  #coord_sf(crs = 26911) + 
  scale_fill_viridis_c(option = "magma") 

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

tst <- 
  fips_tract %>%
  rename_all(list(~str_to_lower(.))) %>%
  rename_at(vars(any_of(c('statefp','countyfp'))),list(~str_replace(.,"fp$","_id"))) %>%
  rename_at(vars(any_of(c('tractce','blkgrpce'))),list(~str_replace(.,"ce$","_id"))) %>%
  rename(pop = estimate, name = name.y) %>%
  select(-affgeoid,-name.x,-variable,-lsad) %>%
  st_as_sf(sf_column_name = "geometry") %>%
  # Label tract-specific vars with '_tract' suffix
  rename_at(vars(!ends_with("_id")),list(~paste0(.,"_tract"))) 

# Save as .shp, since SQL can't hold nested lists  
sf::st_write(fips_tract,"data/fips_tract.shp",append=F)