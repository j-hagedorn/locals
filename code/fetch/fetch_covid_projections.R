## fetch_covid_projections.R

library(tidyverse); library(lubridate)

fetch_covid_projections <- function(url, df){
  
  # Download zipped folder to tempfile and unzip
  url <- paste0(url)
  temp_zip   <- tempfile()
  temp_unzip <- tempfile()
  download.file(url, temp_zip)
  unzip(zipfile = temp_zip, exdir = temp_unzip)
  
  df <- read.csv(paste0(temp_unzip, df))
  
  unlink(c(temp_zip, temp_unzip))
  
  return(df)
  
}

# Sample

projection_5mobility <- fetch_covid_projections(
  url = "https://github.com/SenPei-CU/COVID-19_US_Projection/raw/master/Projection_5%25mobility.csv.zip",
  df = "/Projection_5%mobility.csv"
)

projection_50transmissibility <- fetch_covid_projections(
  url = "https://github.com/SenPei-CU/COVID-19_US_Projection/raw/master/Projection_50%25transmissibility.csv.zip",
  df = "/Projection_50%transmissibility.csv"
)

projection_75transmissibility <- fetch_covid_projections(
  url = "https://github.com/SenPei-CU/COVID-19_US_Projection/raw/master/Projection_75%25transmissibility.csv.zip",
  df = "/Projection_75%transmissibility.csv"
)

projection_nointervention <- fetch_covid_projections(
  url = "https://github.com/SenPei-CU/COVID-19_US_Projection/raw/master/Projection_nointervention.csv.zip",
  df = "/Projection_nointervention.csv"
)
