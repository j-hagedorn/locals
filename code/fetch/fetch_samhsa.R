library(tidyverse)
library(readxl)


locals_db <- DBI::dbConnect(odbc::odbc(), "locals")


# The data needs to be manually pulled from the SAMHSA website facility locator. At a national 
# level, the website only allowed a downloaded in chucks of 30,000. However, they only offer 
# two chunks even with 92,000 datapoints. Therfore, this covers about 2/3 of the national 
# treatment facility dictionary. 

# I've place the downloaded files in the folder GitHub/locals/data/samhsa/


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


