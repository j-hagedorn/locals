library(DBI)
library(tidyverse)
library(nycflights13)
library(data.table)
library(bcputility)

# For this to work you need to download the BCP utility tool from Microsoft
# Download the x64 version 

# https://docs.microsoft.com/en-us/sql/tools/bcp-utility?ranMID=24542&ranEAID=je6NUbpObpQ&ranSiteID=je6NUbpObpQ-mLOm6RfVOulWK_T.B8fIHQ&epi=je6NUbpObpQ-mLOm6RfVOulWK_T.B8fIHQ&irgwc=1&OCID=AID2200057_aff_7593_1243925&tduid=(ir__cxsbcrnm2skf6xgg6nvoq2ofzv2xtfsjbtswwmep00)(7593)(1243925)(je6NUbpObpQ-mLOm6RfVOulWK_T.B8fIHQ)()&irclickid=_cxsbcrnm2skf6xgg6nvoq2ofzv2xtfsjbtswwmep00&view=sql-server-ver15
# use default configurations 

# You will need to specify the exact path to the BCP utility tool 
# It will likely be very similar to this path, but you should double-check. 
options(bcputility.bcp.path = "C:/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/bcp.exe")

start<-Sys.time()

bcpImport(
  acs5_tract, # The data frame you wish to upload
  trustedconnection = FALSE, # If TRUE, I believe this will try to Windows authenticate. 
  driver = "ODBC Driver 17 for SQL Server",
  server = Sys.getenv("wsu_proj_server"),
  database = Sys.getenv('wsu_proj_db'),
  username = Sys.getenv('wsu_uid'),
  password = Sys.getenv("wsu_pw"),
  table  = 'flights_1', # Name of the table to store the data frame you with to upload
  batchsize = 50000, # Feel free to mess around with figure. This was a recommendation. 
  overwrite = T, # Will overwrite the table or create a table if one dosen't exist
  
)

stop <-Sys.time()
stop-start

