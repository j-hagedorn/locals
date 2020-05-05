## fetch_fips.R

library(httr); library(readxl)

GET("https://www2.census.gov/programs-surveys/popest/geographies/2018/state-geocodes-v2018.xlsx", 
    write_disk(tf <- tempfile(fileext = ".xlsx")))

state_fips <- read_excel(tf, skip = 4, col_names = TRUE) 


GET("https://www2.census.gov/programs-surveys/popest/geographies/2018/all-geocodes-v2018.xlsx", 
    write_disk(tf <- tempfile(fileext = ".xlsx")))

all_fips <- read_excel(tf, skip = 3, col_names = TRUE) %>%
  mutate(
    county_state_fips = paste0(`State Code (FIPS)`, `County Code (FIPS)`),
    county_state_fips = as.integer(county_state_fips)
  )
  
