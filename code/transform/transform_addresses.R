library(tidycensus)
library(tidyverse)
library(httr)
library(jsonlite)
library(leaflet)
library(sf)
library(ggmap)
library(DBI)
library(lubridate)


#========================
# Creating the function 
#========================

lat_lon_to_census_block_converter<-function(x){
  
  
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


#===========================================
# Ping API for conversion for Hospital Data 
#===========================================

hospitals_latlon<-hospitals%>%
                  select(lat = LATITUDE, lon = LONGITUDE)%>%
                  distinct()%>%
                  drop_na()

hospitals_block<-lat_lon_to_census_block_converter(hospitals_latlon)

hospitals1<-hospitals%>%
            rename(lat = LATITUDE, lon = LONGITUDE
            )%>%
            left_join(hospitals_block, c("lat","lon")
            )%>%
            mutate(state_zip = paste(STATE,ZIP,sep = " "),
                   address = paste(tolower(ADDRESS),tolower(CITY),state_zip,"USA",sep = ","),
                   dataset = "hospitals")%>%

select(dataset,lat,lon,address,block_id,blkgrp_id,name = NAME,capacity = BEDS,type = TYPE,val_date = VAL_DATE,
       status = STATUS,website = WEBSITE,contact = TELEPHONE)


#============================================================
# Ping API for conversion for local law enforement locations
#============================================================

law_enf_latlon<-law_enf%>%
  select(lat = LATITUDE, lon = LONGITUDE)%>%
  distinct()%>%
  drop_na()

law_enf_block<-lat_lon_to_census_block_converter(law_enf_latlon)

law_enf1<-law_enf%>%
  rename(lat = LATITUDE, lon = LONGITUDE
  )%>%
  left_join(law_enf_block, c("lat","lon")
  )%>%
  mutate(state_zip = paste(STATE,ZIP,sep = " "),
         address = paste(tolower(ADDRESS),tolower(CITY),state_zip,"USA",sep = ","),
         capacity = NA,
         dataset = "law enforcement")%>%

  select(dataset,lat,lon,address,block_id,blkgrp_id,name = NAME,capacity,type = TYPE,val_date = VAL_DATE,
         status = STATUS,website = WEBSITE,contact = TELEPHONE)

  
  
#===========================================
# Ping API for conversion for nursing homes 
#===========================================


nursing_latlon<-nursing%>%
  select(lat = LATITUDE, lon = LONGITUDE)%>%
  distinct()%>%
  drop_na()

nursing_block<-lat_lon_to_census_block_converter(nursing_latlon)

nursing1<-nursing%>%
  rename(lat = LATITUDE, lon = LONGITUDE
  )%>%
  left_join(nursing_block, c("lat","lon")
  )%>%
  mutate(state_zip = paste(STATE,ZIP,sep = " "),
            address = paste(tolower(ADDRESS),tolower(CITY),state_zip,"USA",sep = ","),
            dataset = "nursing")%>%
  
  select(dataset,lat,lon,address,block_id,blkgrp_id,name = NAME,capacity = BEDS,type = TYPE,val_date = VAL_DATE,
         status = STATUS,website = WEBSITE,contact = TELEPHONE)


#=====================================================================
# Prisons locations need to ping both google API to convert addresses
# to lat lon then the FCC API to get block grp and tract info
#=====================================================================

register_google(key =  Sys.getenv("my_google_maps_api"))

prison_addresses<-prison%>%
                  mutate(
                  state_zip = paste(STATE,ZIP,sep = " "),
                  address = paste(tolower(ADDRESS),tolower(CITY),state_zip,"USA",sep = ","))%>%
                  select(address)%>%
                  distinct()

 #ping google with just addresses 
prison_latlon<-prison_addresses%>%
               mutate_geocode(address, output = "more")

#table(prison_latlon$loctype)

##%%%%%%%%%%%%%%%%%%% PICL UP HERE 

prisont_latlon_selected<-prison_latlon%>%
                         select(address,lat,lon)%>%
                         drop_na()

 # use google lat/lon to ping FCC api for Census blocks 
 prison_block<-lat_lon_to_census_block_converter(prisont_latlon_selected)
 
 
prison1<-prison%>%
   mutate(
     state_zip = paste(STATE,ZIP,sep = " "),
     address = paste(tolower(ADDRESS),tolower(CITY),state_zip,"USA",sep = ","))%>%
     left_join(prison_block,by = 'address')%>%
     mutate(dataset = 'prisons')%>%
  
  select(dataset,lat,lon,address,block_id,blkgrp_id,name = NAME,capacity = CAPACITY,type = TYPE,val_date = VAL_DATE,
         status = STATUS,website = WEBSITE,contact = TELEPHONE)  
 


#======================
# Ping API for LARA 
#======================

MSHN_TBD_db <- DBI::dbConnect(odbc::odbc(),"MSHN_TBD")


LARA_Query<-{c("select distinct
 dataset = 'LARA'
,FcltyLat as lat
,FcltyLon as lon 
,address
,FacilityName as name
,Capacity as capacity 
,Effective as val_date 
,FacilityType as type
,Expiration as status 
,website = 'NA'
,LicenseePhone as contact 
from [MSHN_TBD].[dbo].[lara_geocoded]")}

LARA<-dbGetQuery(MSHN_TBD_db,LARA_Query)

lara_latlon<-LARA%>%
                select(lat,lon)%>%
                distinct()%>%
                drop_na()

lara_block<-lat_lon_to_census_block_converter(lara_latlon)



lara1<-LARA%>%
       left_join(lara_block, c("lat","lon"))%>%
       mutate(status = case_when( ymd(status)<=today() ~ 'expired',
                                   ymd(status)> today() ~ "open",
                                   TRUE ~ NA_character_))%>%
  select(dataset,lat,lon,address,block_id,blkgrp_id,name,capacity,type,val_date,
         status,website,contact)  


#================
# RBIND tables
#================

full_dataset <- rbind(hospitals1,law_enf1,nursing1,prison1,lara1)


#=======================
#Puch back to database
#=======================

# database connection 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")


 
 copy_to(
   dest = locals_db,
   df = full_dataset,
   name = "addresses",
   overwrite = T,
   temporary = F
 )
 




