library(tidyverse)
library(readxl)

# Script assumes fetch_samhsa was run first. 

locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

df1<-
  read_excel("C:/Users/joet/Documents/GitHub/locals/data/samhsa/facility_data_chunk1.xlsx",
             sheet = 1)

df2<-
  read_excel("C:/Users/joet/Documents/GitHub/locals/data/samhsa/facility_data_chunk2.xlsx",
             sheet = 1) 

df<-bind_rows(df1,df2) 

code_ref<-
  read_excel("C:/Users/joet/Documents/GitHub/locals/data/samhsa/facility_data_chunk1.xlsx",sheet = 2) %>%
  select(service_code,category_name,service_name,service_desc = service_description) %>%
  distinct()



#Level of grain



treatment_addresses<-
  df %>%
  #  filter(state == 'MI') %>%
  pivot_longer(colnames(df[18:ncol(df)]),names_to = 'service_code' ) %>%
  mutate(
    service_code = str_to_upper(service_code)
    ,name = paste(name1,name2,sep = "-")
  ) %>%
  # Removing service names that are NA 
  filter(!is.na(value)) %>%
  # Joining code reference for human readable names 
  left_join(code_ref, by = 'service_code' ) %>%
  select(
    name,street = street1,city,zip,state,zip,county,
    lat = latitude,lon = longitude,phone,website, category_name,service_name,
    service_desc
  ) %>%
  distinct()



# Inserting into the database 


DBI::dbWriteTable(locals_db,'samhsa_treatment_addresses',treatment_addresses,overwrite = TRUE)





