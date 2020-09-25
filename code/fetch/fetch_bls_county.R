library(tidyverse)
library(blsAPI)
library(rjson)
library(curl)
library(readxl)
library(RCurl)
library(gdata)

full<-list()


for(i in seq(10,19,by = 1)){

url<-paste("https://www.bls.gov/lau/laucnty",i,".txt",sep = "")  
  
df<-read_table(url,skip = 4)

full[[i]]<-df

}


  
employ_data<-do.call("rbind",full)
  
  
#MichiganData <- blsQCEW('Area', year='2017', quarter='1', area='26000')
 
 
 
 
 
 
 
 