
library(tidyverse); library(lubridate); library(feather)

fetch_oi_county <- function(){
  
  # Download zipped folder to tempfile and unzip
  url <- paste0("https://opportunityinsights.org/wp-content/uploads/2018/10/county_outcomes.zip")
  temp_zip   <- tempfile()
  temp_unzip <- tempfile()
  download.file(url, temp_zip)
  unzip(zipfile = temp_zip, exdir = temp_unzip)
  
  df <- read.csv(paste0(temp_unzip,"/county_outcomes.csv"))
  
  unlink(c(temp_zip, temp_unzip))
  
  write_feather(df,"../data/oi_county.feather")
  
  # Download zipped folder to tempfile and unzip
  url <- paste0("https://opportunityinsights.org/wp-content/uploads/2018/12/cty_covariates.csv")
  temp   <- tempdir()
  download.file(url, paste0(temp,"/county_covariates.csv"))

  oi_covar <- read.csv(paste0(temp,"/county_covariates.csv"))

  write_feather(oi_covar,"../data/oi_covar_county.feather")
  
  return(df)
  
}


# Sample:
# oi_tract <- fetch_oi_tract()



