library(tidyverse)
library(readxl)
library(DBI)
library(odbc)
library(ggmap)


# This script pulls from our local NPPES dataset and CMS to compile a list of all 
# psychiatric hospitals and their addresses. 


#===============================#
# Connections & Functions  ====
#===============================#

# Database connections

locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

# Must have Google api registered 
register_google(Sys.getenv('my_google_maps_api'))

# Lat Long to Census Block Converter Function - Requires a dataframe of distinct lat lon
lat_lon_to_census_block_converter<-function(x){
  
  library(httr)
  library(jsonlite)
  
  df<-data.frame()  
  
  for(i in 1:nrow(x)){
    
    geo_data<-x[i,]  
    
    request<-paste("https://geo.fcc.gov/api/census/block/find?latitude=",
                   geo_data$lat,"&longitude=",
                   geo_data$lon,"&showall=true&format=json",sep = "")
    
    response<-GET(request)
    
    response<-content(response,as = "text")
    
    # Detecting intersectional block groups.
    # sometimes a lat/lon falls on a boundry which messes 
    # with the format. If that happens, I take the first
    # block number of the 4 potential and use that. 
    
    response<-if(str_detect(response,'messages') == FALSE & str_detect(response,"null") == FALSE){
      
      response<-fromJSON(response,flatten = TRUE)
      
      response<-as.data.frame(response)%>%
        dplyr::select(Block.FIPS,County.FIPS)%>%
        dplyr::distinct()
      
    }else if(str_detect(response,'messages') == TRUE & str_detect(response,"null") == FALSE){
      
      
      response_data<-read.table(textConnection("{\"messages\":[\"FCC0001: The coordinate lies on the boundary of mulitple blocks.\"],\"Block\":{\"FIPS\":\"260030002001254\",\"bbox\":[-86.908021,46.347416,-86.887139,46.354747],\"intersection\":[{\"FIPF\":\"260030002001254\"},{\"FIPF\":\"260030002001248\"},{\"FIPF\":\"260030002001171\"}]},\"County\":{\"FIPS\":\"26003\",\"name\":\"Alger\"},\"State\":{\"FIPS\":\"26\",\"code\":\"MI\",\"name\":\"Michigan\"},\"status\":\"OK\",\"executionTime\":\"0\"}"),
                                sep = ",")%>%
        mutate(block = as.character(V2),
               county = as.character(V10))
      
      response<-data.frame(Block.FIPS = substring(response_data$block,13,nchar(response_data$block)),
                           County.FIPS = substring(response_data$county,14,nchar(response_data$county)))
      
      
    }else {response<-data.frame(Block.FIPS = NA,
                                County.FIPS = NA)}
    
    
    geo_data$block_id<-response$Block.FIPS
    geo_data$county_id<-response$County.FIPS
    
    geo_data<-geo_data%>%
      mutate( blkgrp_id = substr(as.character(block_id),1,12))
    
    df<-rbind(df,geo_data)
    
  }
  
  return(df)  
  
} 

# Reverse Geo code Function - Requires a dataframe of distinct lat lon
rev_geocode_fun<-function(x){
  
  
  
  df_rev_geocode_address<-tibble()
  
  
  for(i in 1:nrow(x)){
    
    
    
    lat<-as.numeric(unlist(x[i,1]))  
    
    lon<-as.numeric(unlist(x[i,2])) 
    
    
    google_address<-revgeocode(c(lon,lat),output = "address")
    
    return_df<-tibble(x[i,],google_address)
    
    df_rev_geocode_address<-bind_rows(df_rev_geocode_address,
                                      
                                      return_df)
    
  }
  
  return(df_rev_geocode_address)
  
}


#============================#
# Fetching NPI Data  ====
#============================#

npi<-dbGetQuery(locals_db,{
  "
SELECT * 
FROM [locals].[dbo].[npi_org_locations]
where [state] = 'MI'
and taxonomy in 
(


--'261QR0405X', -- Ambulatory Health Care Facilities - Clinic/Center -Rehabilitation, Substance Use Disorder
'320800000X', -- Community Based Residential Treatment Facility, Mental Illness
'323P00000X', -- Psychiatric Residential Treatment Facility
'283Q00000X', -- Psychiatric Hospital
'261QM0855X', -- Ambulatory Health Care Facilities - Adolescent and Children Mental Health
'273R00000X'  -- Psychiatric Unit
--'261QM0801X' -- Ambulatory Health Care Facilities - Mental Health (Including Community Mental Health Center)
--'261QM0850X'  -- Ambulatory Health Care Facilities - Adult Mental Health
)  

or (taxonomy = '251E00000X' and taxonomy_2 = '323P00000X') -- Home Health primary NPI and Psychiatric Residential Treatment Facility secondary

  
  
"})
  
  

#===========================#
# Formatting CMS Data  ====
#===========================#

#https://catalog.data.gov/dataset/inpatient-psychiatric-facility-quality-measure-data-by-facility/resource/19ea4fda-9e6d-402c-80b8-f6540c95abe1
  
  
 
cms<-read_csv("data/samhsa/cms_inpatient_psychiatric_facility.csv") %>%
  filter(State == 'MI') %>%
  rename_with(tolower)%>%
  rename_with(str_squish)%>%
  rename_with(~str_replace_all(., " |-", "_")) %>%
  select(2:6) %>%
  mutate(             
    Encaddress = paste(str_squish(str_to_lower(address)),",",
                       str_squish(str_to_lower(city)),",",
                       str_squish(str_to_lower(state))," ",
                       str_squish(str_to_lower(zip_code)),",",
                       "usa",sep = "") 
  )


# Geocoding the addresses 


cms_coord<-
  cms %>%
  select(Encaddress) %>%
  distinct()


cms_geocoded<-cms_coord%>%
  mutate_geocode(Encaddress, output = "more") 

# Joining back to the original dataset with further manipulations 
# to match locals columns. 

cms<-
  cms %>%
  left_join(
    cms_geocoded%>%
      select(Encaddress,lat,lon,loctype,
             google_address = address), 
    by = "Encaddress"
  ) %>%
  mutate(
    dataset = 'cms',
    type = 'psychiatric_inpatient_hsptl',
    address = google_address,
    capacity = NA_character_,
    contact = NA_character_,
    website = NA_character_,
    val_date = NA_character_,
    fk_type = NA_character_,
    status = NA_character_,
    name = facility_name
  ) %>%
  mutate_if(is.character,str_to_lower)

# Obtaining the block group IDS associated with the lat/lon


cms_latlon<-
  cms%>%
  select(lat, lon)%>%
  distinct()%>%
  drop_na()

cms_block<-lat_lon_to_census_block_converter(cms_latlon)

cms<-
  cms%>%
  left_join(cms_block%>%
              select(-county_id), c("lat","lon")
  ) %>%
  select(names(samhsa))

rm(cms_block,cms_cr_geocoded,cms_latlon)