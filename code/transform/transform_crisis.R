library(tidyverse)
library(readxl)
library(DBI)
library(odbc)
library(ggmap)

locals_db <- DBI::dbConnect(odbc::odbc(), "locals")


mi_fclty<-read_excel("data/samhsa/mi_facility_data.xlsx")


code_ref<-
  read_excel("data/samhsa/mi_facility_data.xlsx",sheet = 2) %>%
  select(service_code,category_code,category_name,service_name,service_desc = service_description)
  

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

# Reverse Geocode Function - Requires a dataframe of distinct lat lon
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


#=================================#
# Address Dataset Locals Data  ====
#=================================# 

locals<-dbGetQuery(locals_db,{
  "SELECT 
*
FROM [locals].[dbo].[addresses]
where dataset in ('hospitals')
and type in ('PSYCHIATRIC','REHABILITATION')

"}) %>%
  mutate(address1 = address) %>%
  separate(
    address,into = c('street','city','state_zip','country'), sep = ","
  ) %>%
  mutate(
    state = substr(state_zip,1,2)) %>%
  filter(
    state == 'MI', 
    status == 'OPEN') %>%
  select(-c('street','city','state_zip','country','state'))%>%
  rename(address = address1)

# Reverse geo coding lat lons to get a Google formatted address   

df_coord<-
  locals %>%
  select(lat,lon) %>%
  distinct() 

locals_geocoded<-rev_geocode_fun(df_coord)


locals<-
  locals %>%
  left_join(df_coord, by = c('lat',"lon")) %>%
  select(dataset,lat,lon,block_id,blkgrp_id,name,capacity,
         type,val_date,status,website,contact,address) %>%
  mutate(fk_type = NA_character_,
         capacity = as.character(capacity)) %>%
  mutate_if(is.character,str_to_lower)

rm(locals_geocoded,df_coord)

#=================================#
# Formatting SAMHSA Data  ====
#=================================# 

# Remove rows where all designations are true 


df<-
  mi_fclty %>%
  
 # filter(name1 == 'MIDMICHIGAN MEDICAL OFFICES') %>%
  mutate(
    # Removing anyone with obvious strings in thier name to determine they are a person, 
    # not an orginization.
    person = case_when(str_detect(name1,"Dr.|dr.|MD|M.D.|DO|D.O.|NP") ~ 1, 
                       T ~ 0), 
    # Removing anyone flagged as a VA medical center 
    va_med_center = case_when(vamc == 1 ~ 1, 
                              T ~ 0)
    
  
  ) %>%
  filter(
    va_med_center == 0,
    person == 0 ) %>%
  select(-person,-va_med_center) %>%
  select(
    -c(type_facility,city,state,county,name2),
    -starts_with(c("intake","street","zip"))
     ) %>%
  select(name = name1,phone,website,
         lat = latitude, lon = longitude,everything()
         ) %>%
  distinct() %>%
  # Pivot longer to join facility types 
  pivot_longer(-c(name,phone,website,lat,lon), names_to = 'service_code') %>%
  group_by(name,phone,website,lat,lon) %>%
  mutate(
    total_designations = sum(as.numeric(value),na.rm = T),
    no_info = case_when(total_designations >= 262 & is.na(website)==T ~ 1, 
                        T ~ 0)
    ) %>%
  ungroup() %>%
  filter(total_designations < 260 ) %>%
  select(-c(total_designations,no_info)) %>%
  # Removing NA values from value column 
  filter(!is.na(value)) %>%
  mutate(service_code = str_to_upper(service_code)) %>%
  # Joining code reference for human readable names 
  left_join(code_ref, by = 'service_code' ) %>%
  # Only Including the types listed in the document 
  filter(service_name %in% c('Psychiatric emergency walk-in services',
                          #   'Psychiatric hospital or psychiatric unit of a general hospital',
                          #   'Psychiatric hospital',
                             'Crisis intervention team',
                             'Psychiatric emergency onsite services',
                             'Psychiatric emergency mobile/off-site services') )


# Creating loop to reverse geocode ====


register_google(key = Sys.getenv("my_google_maps_api") )


# The function requires two column for lat lon coordinates. 
# these lat/lon also serve as the key to joining the data back 
# to the original. 

df_coord<-
  df %>%
  select(lat,lon) %>%
  distinct() 


rev_geodode_results<-rev_geocode_fun(df_coord)

# joining back to the original data set 

samhsa<-
  df %>%
  left_join(rev_geodode_results, by = c("lat","lon")) %>%
  select(address = google_address,name,
         contact = phone,website,lat,lon,type = service_name, 
         fk_type = service_code
         ) %>%
  mutate(
    address = str_to_lower(address), 
    dataset = 'samhsa', 
    capacity = NA_character_,
    status = NA_character_,
    val_date = NA_character_,
    lat = as.numeric(lat),
    lon = as.numeric(lon)
  )



# Obtaining the block group IDS associated with the lat/lon


samhsa_latlon<-samhsa%>%
  select(lat, lon)%>%
  distinct()%>%
  drop_na()

samhsa_block<-lat_lon_to_census_block_converter(samhsa_latlon)

# Joining block data back and making last minute formatting changes to 
# allow for the binding of rows later on. 

samhsa<-
  samhsa%>%
  left_join(samhsa_block%>%
              mutate(    
                lat = as.numeric(lat),
                 lon = as.numeric(lon)
                         )%>%
              select(-county_id), c("lat","lon")
  ) %>%
  select(names(locals),fk_type)

# A single location can qualify as many types. To help reduce duplicates, I'm
# placing all types for a location on one row separated by commas. 
samhsa<-
  samhsa %>%
  group_by(lat,lon,name,block_id) %>%
  mutate(type =  paste(type, collapse = " , "), 
         fk_type = paste(fk_type, collapse = " , ")) %>%
  ungroup() %>%
  distinct()

rm(samhsa_block,samhsa_latlon,rev_geodode_results)
#==========================================#
# Formatting Internal Crisis Database ====
#==========================================#


internal_list<-read_excel("data/samhsa/internal_crisis_list.xlsx", sheet = 2)


df<-
  internal_list %>%
  filter(State == 'MI') %>%
mutate(             
  Encaddress = paste(str_squish(str_to_lower(`Address 1`)),",",
              str_squish(str_to_lower(City)),",",
              str_squish(str_to_lower(State))," ",
              str_squish(str_to_lower(Zip)),",",
              "usa",sep = "") 
)


# Geocoding the addresses 


crisis_coord<-
  df %>%
  select(Encaddress) %>%
  distinct()


internal_cr_geocoded<-crisis_coord%>%
  mutate_geocode(Encaddress, output = "more") 

# Joining back to the orginal dataset with further manipulations 
# to match locals columns. 

internal_crisis<-
  df %>%
  left_join(
    internal_cr_geocoded%>%
      select(Encaddress,lat,lon,loctype,
             google_address = address), 
    by = "Encaddress"
  ) %>%
  mutate(
    dataset = 'internal',
    type = Classification,
    address = google_address,
    capacity = `Number of Beds`,
    contact = Phone,
    website = Website,
    val_date = NA_character_,
    fk_type = NA_character_,
    status = NA_character_,
    name = Name
) %>%
  mutate_if(is.character,str_to_lower)
  
# Obtaining the block group IDS associated with the lat/lon
  
  
internal_latlon<-
  internal_crisis%>%
  select(lat, lon)%>%
  distinct()%>%
  drop_na()

internal_block<-lat_lon_to_census_block_converter(internal_latlon)

internal_crisis<-
  internal_crisis%>%
  left_join(internal_block%>%
              select(-county_id), c("lat","lon")
  ) %>%
  select(names(samhsa))

rm(internal_block,internal_cr_geocoded,internal_latlon)

#============================#
# Formatting NPI Data  ====
#============================#

npi<-dbGetQuery(locals_db,{
  "
SELECT * 
FROM [locals].[dbo].[npi_org_locations]
where [state] = 'MI'
and taxonomy in 
(

--'261QR0405X', -- Ambulatory Health Care Facilities - Clinic/Center -Rehabilitation, Substance Use Disorder
--'320800000X', -- Community Based Residential Treatment Facility, Mental Illness
'323P00000X', -- Psychiatric Residential Treatment Facility
'283Q00000X', -- Psychiatric Hospital
'261QM0855X', -- Ambulatory Health Care Facilities - Adolescent and Children Mental Health
'273R00000X', -- Psychiatric Unit
'261QM0801X'  -- Ambulatory Health Care Facilities - Mental Health (Including Community Mental Health Center)
)  

and provider_name not like '%PLLC%' 
  
  
  
"})
  



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



npi1<-
  npi %>%
  filter(address == '1852 w grand blvd, detroit, mi 48208, usa') %>%
 distinct() %>%
  group_by(address,type) %>%
  filter(name == max(name,na.rm = T)) %>%
  ungroup()%>%
  distinct()

  
#===========================#
# Testing various joins =====
#============================#


# Union 

df<-bind_rows(samhsa
              ,npi
             # ,locals
              ,internal_crisis)


test<-
  df %>%
  select(dataset,address) %>%
  distinct()

table(test$dataset)
  


test<-
  df%>%
  group_by(address)%>%
  summarise(n = n_distinct(dataset)) %>%
  ungroup() %>%
  filter(n>1) %>%
  select(address) %>%
  pull()


test<-
  df %>%
  filter(address == '33505 schoolcraft, livonia, mi 48150, usa')

test<-
  df %>%
  filter(type == 'Psychiatric emergency walk-in services')

test<-
  df %>%
  filter(address == '1 ford pl, detroit, mi 48202, usa')


test<-
  df %>%
  filter(address %in% test) %>%
  select(dataset,address,type) %>%
  distinct()



# left joins 
table(internal_crisis$type)

test_fill <-df %>%
  filter(!fk_type %in% c('261QM0801X')) %>%
  filter(!dataset == 'internal') %>%
  select(address,dataset,type,name) %>%
  mutate(
    name = str_to_lower(name)
         ) %>%
  distinct() %>%
  group_by(address) %>%
  mutate(matched_other_types =  paste(type, collapse = " , "),
         matched_other_datasets = paste(dataset, collapse = " , ")) %>%
  ungroup() %>%
  select(address,matched_other_datasets,matched_other_types,name_other = name) %>%
  distinct()

  
test_match<-
    internal_crisis %>%
    filter(type %in% c('crisis residential (adult)','crisis residential (adult)',
                       'mobile crisis team','23-hour csu','Locked CSU')) %>%
    left_join(test_fill%>%
                mutate(
                       address_match= paste0(address," - Other" ))
              
              ,
              by = 'address') %>%
  distinct() %>%
  select(name,address,type,matched_other_datasets,matched_other_types) %>%
  distinct()



test <-df %>%
  filter(fk_type %in% c('323P00000X'))



test<-df%>%
  select(dataset,everything())



