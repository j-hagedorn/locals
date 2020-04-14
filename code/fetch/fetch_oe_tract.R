
library(tidyverse); library(lubridate)

fetch_oi_tract <- function(){
  
  # Download zipped folder to tempfile and unzip
  url <- paste0("https://opportunityinsights.org/wp-content/uploads/2018/10/tract_outcomes.zip")
  temp_zip   <- tempfile()
  temp_unzip <- tempfile()
  download.file(url, temp_zip)
  unzip(zipfile = temp_zip, exdir = temp_unzip)
  
  df <- read.csv(paste0(temp_unzip,"/tract_outcomes_early.csv"))
  
  unlink(c(temp_zip, temp_unzip))
  
  return(df)
  
}


# Sample:
# oi_tract <- fetch_oi_tract()



