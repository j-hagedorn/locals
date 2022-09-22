library(tidyverse)
library(DBI)
library(data.table)
library(bcputility)


# Push data to the database



# You will need to specify the exact path to the BCP utility tool 
# It will likely be very similar to this path, but you should double-check. 
options(bcputility.bcp.path = "C:/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/bcp.exe")

start<-Sys.time()

bcpImport(
  df, # The data frame you wish to upload
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

