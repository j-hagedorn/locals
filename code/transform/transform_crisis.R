library(tidyverse)
library(readxl)
library(DBI)
library(odbc)

locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

df1<-
  read_excel("C:/Users/joet/Documents/GitHub/locals/data/samhsa/facility_data_chunk1.xlsx",
             sheet = 1)

df2<-
  read_excel("C:/Users/joet/Documents/GitHub/locals/data/samhsa/facility_data_chunk2.xlsx",
             sheet = 1)

df<-bind_rows(df1,df2)


mi_fclty<-read_excel("data/samhsa/mi_facility_data.xlsx")


code_ref<-
  read_excel("data/samhsa/mi_facility_data.xlsx",sheet = 2) %>%
  select(service_code,category_code,category_name,service_name,service_desc = service_description)
  
  

df<-
  mi_fclty %>%
  mutate(    street = case_when(str_detect(substring(street1, 1, 1),'[0-9]') == TRUE ~ street1,
                                 TRUE~ street2) , 
             
             name = case_when(str_detect(substring(street1, 1, 1),'[0-9]') == FALSE ~ street1,
                              T ~ name1), 
  
             address = paste(str_squish(str_to_lower(name)),",",
                             str_squish(str_to_lower(street)),",",
                             str_squish(str_to_lower(state))," ",
                             str_squish(str_to_lower(zip)),",",
                             "usa",sep = "") 
  ) %>%
  select(
    -c(type_facility,city,state,county),
    -starts_with(c("intake","street","name","zip"))
     ) %>%
  select(address,phone,website,lat = latitude, lon = longitude,everything()) %>%
  # Pivot longer to join facility types 
  pivot_longer(-c(address,phone,website,lat,lon), names_to = 'service_code') %>%
  # Removing NA values from value column 
  filter(!is.na(value)) %>%
  mutate(service_code = str_to_upper(service_code)) %>%
  # Joining code reference for human readable names 
  left_join(code_ref, by = 'service_code' ) %>%
  # Only Including the types listed in the document 
  filter(service_name %in% c('Psychiatric emergency walk-in services') )





# Full list 
# 
# c('Transitional housing, halfway house, or sober home',
#   'Suicide prevention services','Community mental health center',
#   'Psychiatric hospital or psychiatric unit of a general hospital',
#   'Psychiatric hospital','Crisis intervention team',
#   'Psychiatric emergency onsite services',
#   'Psychiatric emergency mobile/off-site services',
#   'Psychiatric emergency walk-in services')


