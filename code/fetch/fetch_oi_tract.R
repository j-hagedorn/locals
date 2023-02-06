library(tidyverse)
library(readxl)
library(DBI)
library(data.table)
library(bcputility)


web_address<-'https://opportunityinsights.org/wp-content/uploads/2018/10/tract_outcomes.zip'

dir.create("temp")

url <- web_address
path_zip <- "temp"
path_unzip <- "temp"
destfile <- "archive.zip"
memory<-memory.limit()

# download zip
curl::curl_download(url, destfile = paste(path_zip, destfile, sep = "/"))

# unzip
unzip(zipfile = paste(path_zip, destfile, sep = "/"), exdir = path_unzip)

# list all files and grab the file with NPI addresses 
outcomes = read_csv("temp/tract_outcomes_early.csv",
                    col_select = c("state",
                                   "county",
                                   "tract",
                                   "jail_pooled_pooled_mean",
                                   'teenbrth_pooled_female_mean'))

outcomes = 
  outcomes %>% 
  mutate(
    tract = paste0(
      str_pad(state,width = 2,pad = 0),
      str_pad(county,width = 3,pad = 0),
      str_pad(tract,width = 6,pad = 0)),
    
  ) %>% 
  pivot_longer(cols = c(jail_pooled_pooled_mean,teenbrth_pooled_female_mean), 
               names_to = 'variable',values_to = 'value') %>% 
  mutate(
    source = 'opportunity_insights',
    year = '2010',
    var_short_name = case_when(variable == 'jail_pooled_pooled_mean' ~ 'Incarceration Rate', 
                               T ~ 'Teen Birth Rate'),
    var_name = case_when(variable == 'jail_pooled_pooled_mean' ~ 'Fraction incarcerated on April 1st, 2010 per 1K of the Population', 
                         T ~ 'Teen Birth Rate per 1K of the Population'), 
    value = round(value * 1000,0),
    value = if_else(as.numeric(value)<0,0,as.numeric(value))
  ) %>% 
  select(source,year,tract,var_short_name,value,var_name,variable) %>% 
  mutate_all(as.character)

# Remove temp directory 
unlink(path_unzip,recursive = T)
#rm(web_address,url,path_unzip,path_zip,destfile,memory)


#==============================#
# Push data to the database====
#==============================#


# You will need to specify the exact path to the BCP utility tool 
# It will likely be very similar to this path, but you should double-check. 
options(bcputility.bcp.path = "C:/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/bcp.exe")

start<-Sys.time()

bcpImport(
  outcomes, # The data frame you wish to upload
  trustedconnection = FALSE, # If TRUE, I believe this will try to Windows authenticate. 
  driver = "ODBC Driver 17 for SQL Server",
  server = Sys.getenv("tbd_server_address"),
  database = 'locals',
  username = Sys.getenv('tbd_server_uid'),
  password = Sys.getenv("tbd_server_pw"),
  table  = 'tracts', # Name of the table to store the data frame you with to upload
  batchsize = 50000 # Feel free to mess around with figure. This was a recommendation. 
  #overwrite = T # Will overwrite the table or create a table if one dosen't exist
  
)

stop <-Sys.time()
stop-start




















