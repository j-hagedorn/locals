library(tidyverse)
library(RSocrata)
library(DBI)
library(xlsx)
library(data.table)
library(bcputility)

df_places = read.socrata("https://chronicdata.cdc.gov/resource/cwsq-ngmh.json")

state_list =  unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])


df = 
  df_places %>% 
  filter(data_value_type == 'Crude prevalence',
         stateabbr %in% state_list) %>% 
  mutate(dataset = paste("PLACES:",datasource),
         state = substr(countyfips,1,2),
         county = countyfips,
         var = measureid,
         var_name = measure,
         var_short_name = short_question_text,
         value = data_value,
         stat_type = 'frac') %>% 
  select(dataset,year,state,county=countyfips,tract=locationname,year,var,var_name,var_short_name,value,stat_type) %>% 
  mutate_all(as.character)


# You will need to specify the exact path to the BCP utility tool 
# It will likely be very similar to this path, but you should double-check. 
options(bcputility.bcp.path = "C:/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/bcp.exe")

start<-Sys.time()

bcpImport(
  df, # The data frame you wish to upload
  # SQL Connections
  connectargs = makeConnectArgs(
    server = Sys.getenv('tbd_server_address')
    database = 'locals',
    trustedconnection = TRUE
  ), # If TRUE, this will Windows authenticate. Be sure you are connected to the VPN. 
  table  = 'tracts', # Name of the table to store the data frame you wish to upload
  overwrite = F, # Will overwrite the table or create a table if one dosen't exist
  bcpOptions = c('-b 50000') # This refers to the batch size of the number of rows sent at a time.Feel free to mess around with figure. This was a recommendation. 
  # *If an error occurs, ensure all columns are NVARCHAR(MAX) in SQL
)

stop <-Sys.time()
stop-start

