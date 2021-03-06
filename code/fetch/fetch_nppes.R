#=========================================
# Downloading and storing NPPES dataset
#=========================================
library(feather)
library(tidyverse)
library(DBI)
library(lubridate)



nppes_web_address<-paste("https://download.cms.gov/nppes/NPPES_Data_Dissemination_",
                         month.name[month(today()-40)],"_",year(today()),".zip",sep = "")


dir.create("temp")

url <- nppes_web_address
path_zip <- "temp"
path_unzip <- "temp"
destfile <- "archive.zip"
memory<-memory.limit()

# download zip
curl::curl_download(url, destfile = paste(path_zip, destfile, sep = "/"))

# unzip
unzip(zipfile = paste(path_zip, destfile, sep = "/"), exdir = path_unzip)


# list all files and grab the file with NPI addresses 
files <- list.files(path = path_unzip)

npi_data<-files[str_detect(files,"npidata_pfile_")==T & 
                  str_detect(files,"FileHeader")==F ]

# increase memory size to read in file
memory.limit(size = 35000)

# read in file
nppes<-read_csv(paste(path_unzip,npi_data,sep = "/"))

# set memory size back to normal
memory.limit(size = memory)


# Remove temp directory 
unlink(path_unzip,recursive = T)


