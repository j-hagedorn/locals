library(tidyverse)
library(readxl)
library(DBI)
library(odbc)
library(ggmap)





#============================#
# Formatting NPI Data  ====
#============================#


# Geocoding the addresses 

register_google(key = Sys.getenv("my_google_maps_api"))

npi_coord<-
  npi %>%
  select(npi_practice_address) %>%
  distinct()


npi_geocoded<-npi_coord%>%
  mutate_geocode(npi_practice_address, output = "more")   


npi<-
  npi %>%
  left_join(npi_geocoded, by = 'npi_practice_address') %>%
  select(-type) %>%
  mutate(
    dataset = 'nppes',
    name = str_to_lower(provider_name), 
    capacity = NA_character_,
    type = case_when(taxonomy_classification == 'Clinic/Center' ~ 'Ambulatory Clinic/Center', 
                     T ~ taxonomy_classification),
    website = NA_character_,
    fk_type = taxonomy,
    status = "Open",
    val_date = vald_date,
    contact = as.character(contact)
    
  )

# Obtaining the block group IDS associated with the lat/lon

npi_latlon<-
  npi%>%
  select(lat, lon)%>%
  distinct()%>%
  drop_na()

npi_block<-lat_lon_to_census_block_converter(npi_latlon)

npi<-
  npi%>%
  left_join(npi_block%>%
              select(-county_id), c("lat","lon")
  ) %>%
  select(names(samhsa))