
library(tidyverse); library(tidycensus); library(lubridate); library(feather)

search <- "poverty|disability|disabled|over 65|insurance|incarcerat|institutionalized|food stamps"
year_range <- 2013:2018

acs_vars <-
  for(i in year_range) {
    df <- 
      load_variables(year_range[6], "acs5", cache = TRUE) %>%
      filter(str_detect(label,regex(search, ignore_case = T))) %>%
      # mutate(year = i) %>%
      separate()
  }
  

%>%
  select(Name) %>% .$Name

fetch_acs_tract <- function(){
  
  get_acs(geography = "tract", 
          variables = vars, 
          state = "VT", 
          year = 2018)
  
  
  
}