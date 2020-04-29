
library(tidyverse); library(tidycensus); library(lubridate); library(feather)

search <- "poverty|disability|disabled|over 65|insurance|incarcerat"
year_range

acs_vars <-
  for(i in year_range) {
    df <- 
      load_variables(i, "acs5", cache = TRUE) %>%
      filter(str_detect(Label,regex(search, ignore_case = T))) %>%
      # Remove names with 'M' suffix since pkg includes MOE for all vars
      filter(str_detect(Label,"M$")) %>%
      mutate(
        year = i,
        # remove 'E' suffix
        Label = str_remove(Label,"E$")
      )
  }
  

%>%
  select(Name) %>% .$Name

fetch_acs_tract <- function(){
  
  get_acs(geography = "tract", 
          variables = vars, 
          state = "VT", 
          year = 2018)
  
  
  
}