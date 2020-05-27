library(DBI)

df1<-df1%>%
  mutate(
    # if the first characters of field 'street1' are numbers, use that, 
    # otherwise use the 'street2' field.
    street = case_when(str_detect(substring(street1, 1, 1),'[0-9]') == TRUE ~ street1,
                       TRUE~ street2),
    
    # sometimes they put the name of the institution in the street1 column. If the first 
    # chareters are not numeric, use that as the name. 
    name = case_when(str_detect(substring(street1, 1, 1),'[0-9]') == FALSE ~ street1,
                     TRUE~ name1),
    status = case_when(otp == 1 & ub == 1 ~ "otp:bp",
                       otp == 1 & is.na(ub) == T ~ 'otp',
                       ub == 1 & is.na(otp) == T ~ 'bp',
                       TRUE ~ NA_character_),
    lat = latitude,
    lon = longitude
  )%>%
  select(name,street,city,otp,ub,status,
         state,zip,county,phone,website,
         type_facility,lat,lon
  )%>%
  group_by(lat,lon)%>%
  filter(name == max(name,na.rm = T),
         street == max(street,na.rm = T),
         zip == max(zip,na.rm = T))%>%
  ungroup()%>%
  distinct()

#==========================
# Same operations for df2
#==========================

df2<-df2%>%
  mutate(
    # if the first characters of street are numbers, use that, otherwise use the street2
    # field.
    street = case_when(str_detect(substring(street1, 1, 1),'[0-9]') == TRUE ~ street1,
                       TRUE~ street2),
    
    # sometimes they put the name of the institution in the street1 column. If the first 
    # chareters are not numeric, use that as the name. 
    name = case_when(str_detect(substring(street1, 1, 1),'[0-9]') == FALSE ~ street1,
                     TRUE~ name1),
    status = case_when(otp == 1 & ub == 1 ~ "otp:bp",
                       otp == 1 & is.na(ub) == T ~ 'otp',
                       ub == 1 & is.na(otp) == T ~ 'bp',
                       TRUE ~ NA_character_),
    lat = latitude,
    lon = longitude
  )%>%
  select(name,street,city,otp,ub,status,
         state,zip,county,phone,website,
         type_facility,lat,lon
  )%>%
  group_by(lat,lon)%>%
  
  filter(name == max(name,na.rm = T),
         street == max(street,na.rm = T),
         zip == max(zip,na.rm = T))%>%
  ungroup()%>%
  distinct()


samhsa<-rbind(df1,df2)

#=====================================
# geocode lat lons for block groups 
#=====================================

# Creating the function that pings the CDC website 
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


#===========================================
# Ping API for conversion for SAMHSA Data 
#===========================================

samhsa_lat_lon<-samhsa%>%
      select(lat,lon)%>%
      distinct()%>%
      drop_na()


samhsa_block<-lat_lon_to_census_block_converter(samhsa_lat_lon)


samhsa<-samhsa%>%
  left_join(samhsa_block, c("lat","lon")
  )%>%
  mutate(capacity = NA_character_,
         contact = phone,
         type = type_facility,
         val_date = NA_character_,
         state_zip = paste(state,zip,sep = " "),
         address = paste(tolower(street),tolower(city),state_zip,"USA",sep = ","),
         dataset = "samhsa")%>%
 select(dataset,lat,lon,address,block_id,blkgrp_id,name,capacity,type,status,website,contact)




# database connection 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

dbWriteTable(locals_db, name="addresses", value= samhsa , append=T, row.names=F, overwrite=F)


