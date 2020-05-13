
library(tidyverse); library(sf)

get_geo <- function(df = fips, geo_level = "state"){

  # Takes a geographical grouping from FIPS and returns a
  # table with unique rows and names of parent groups for 
  # selected geo_level
  
  x <-
    df %>%
    select(
      ends_with("_id"), starts_with("name_"), 
      ends_with(paste0("_",geo_level))
    ) %>%
    rename_at(
      vars(ends_with(paste0("_",geo_level))),
      list(~str_remove(.,paste0("_",geo_level)))
    ) %>%
    distinct(geoid,.keep_all = T) 
  
  if (geo_level == "state"){
    x <- x %>% select(!matches("county|tract|blkgrp"))
  } else if (geo_level == "county") {
    x <- x %>% select(!matches("tract|blkgrp"))
  } else if (geo_level == "tract") {
    x <- x %>% select(!matches("blkgrp"))
  } else x <- x
  
  x <- x %>% st_as_sf(sf_column_name = "geometry")
  
}


# Example:
# tst <- fips %>% get_geo("county")
# class(tst)


