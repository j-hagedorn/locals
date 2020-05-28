library(haven)
library(tidyverse)
library(purrr)




#===================================
# Function to fetch SAS file inside
# a zipped folder
#===================================

fetch_ahrf <- function(url, df){
  
  # Download zipped folder to tempfile and unzip
  url <- paste0(url)
  temp_zip   <- tempfile()
  temp_unzip <- tempfile()
  download.file(url, temp_zip)
  unzip(zipfile = temp_zip, exdir = temp_unzip)
  
  df <- read_sas(paste0(temp_unzip, df))
  
  unlink(c(temp_zip, temp_unzip))
  
  return(df)
  
}

df <- fetch_ahrf(url = "https://data.hrsa.gov//DataDownload/AHRF/AHRF_2018-2019_SAS.zip",
                 df = "/ahrf2019.sas7bdat")


#===================================
# extracting labels from colnames
# because reading in a SAS file does 
# dumb stuff to col names
#===================================
n <- ncol(df)
labels_list <- map(1:n, function(x) attr(df[[x]], "label") )

# if a vector of character strings is preferable
labels_vector <- map_chr(1:n, function(x) attr(df[[x]], "label") )

colnames(df)<-labels_vector


#============================================
# Function to remove label name duplicates
#===========================================
one_entry <- function(x) {
  for (i in length(x)) attr(x[[i]], "names") <- NULL
  return(x)
}

df<-lapply(df, one_entry)

ahrf_df<-as.data.frame(df)