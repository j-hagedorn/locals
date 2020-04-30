
library(tidyverse); library(tidycensus); library(lubridate); library(feather)

# Because different measures reference different stratification variables 
# in different orders/formats, we need to manually select the best fields 
# to include in the dataset. The query below returns vars which match the 
# search string and are available across the identified date range

search <- "median income|below poverty|with a disability|disabled|over 65|no health insurance|incarcerat|received food stamps"
by_vars <- "sex|age|race"
year_range <- 2013:2018
acs_search <- tibble()

for(i in year_range) {
  df <- 
    load_variables(i, "acs5", cache = TRUE) %>%
    filter(str_detect(label,regex(search, ignore_case = T))) %>%
    filter(str_detect(concept,regex(by_vars, ignore_case = T))) %>%
    mutate(year = i) 
  
  acs_search <- bind_rows(acs_search,df)
}

# Assure vars are available for all years and then reduce
acs_search <- 
  acs_search %>% 
  group_by(name) %>% 
  filter(n_distinct(year) == length(year_range)) %>%
  group_by(name,label,concept) %>%
  summarize() %>%
  separate(label, c(NA,"lab1","lab2","lab3","lab4","lab5","lab6","lab7"), sep = "!!", remove = F)
  
# Explicitly list vars
fields <- list()
fields$below_poverty <- "^B17001[:alpha:]"
fields$median_income <- "B19326_001|B19326_002|B19326_005"
fields$disability    <- "^B18101|^B18101[:alpha:]"
fields$no_insurance  <- "^B27001|^C27001[:alpha:]"

# as_tibble(fields) %>% t()

acs_vars <-
  load_variables(max(year_range), "acs5", cache = TRUE) %>%
  filter(str_detect(name,regex(paste(fields,collapse = "|"), ignore_case = T))) %>%
  filter(str_detect(label,regex(search, ignore_case = T))) %>%
  mutate(
    race = case_when(
      str_detect(concept,regex("\\(hispanic or latino\\)", ignore_case = T))              ~ "hispanic",
      str_detect(concept,regex("\\(black or african american alone\\)", ignore_case = T)) ~ "black",
      str_detect(concept,regex("\\(white alone\\)", ignore_case = T))                     ~ "white",
      str_detect(concept,regex("\\(white alone, not hispanic", ignore_case = T))          ~ "white_nonhisp",
      str_detect(concept,regex("\\(asian alone\\)", ignore_case = T))                     ~ "asian",
      str_detect(concept,regex("\\(american indian", ignore_case = T))                    ~ "natam",
      str_detect(concept,regex("pacific islander", ignore_case = T))                      ~ "pacific",
      str_detect(concept,regex("two or more", ignore_case = T))                           ~ "multiple",
      str_detect(concept,regex("other race", ignore_case = T))                            ~ "other",
      TRUE ~ "pooled"
    ),
    gender = case_when(
      str_detect(label,"Male") ~ "male",
      str_detect(label,"Female") ~ "female",
      TRUE ~ "pooled"
    ),
    age_range = case_when(
      str_detect(label,"Under [:digit:]{1,2} years") ~ str_extract(label,"Under [:digit:]{1,2} years"),
      str_detect(label,"[:digit:]{1,2} to [:digit:]{1,2} years") ~ str_extract(label,"[:digit:]{1,2} to [:digit:]{1,2} years"),
      str_detect(label,"[:digit:]{1,2} and [:digit:]{1,2} years") ~ str_extract(label,"[:digit:]{1,2} and [:digit:]{1,2} years"),
      str_detect(label,"[:digit:]{1,2} years and over") ~ str_extract(label,"[:digit:]{1,2} years and over"),
      str_detect(label,"[:digit:]{1,2} years") ~ str_extract(label,"[:digit:]{1,2} years"),
      TRUE ~ "pooled"
    )
  ) %>%
  fuzzyjoin::regex_left_join(
    fields %>% as_tibble() %>% pivot_longer(cols = everything()) %>% rename(var_name = name),
    by = c("name" = "value")
  ) %>%
  select(name,label,concept,race,gender,age_range,var_name)

# Nake sure there are no duplicate 
# dups <- 
#   acs_vars %>%
#   group_by(var_name,race,gender,age_range) %>%
#   summarize(n_distinct(name))


fetch_acs_tract <- function(){
  
 tst <- 
   get_acs(
     geography = "county", 
     variables = acs_vars$name, 
     state = "MI", 
     year = 2018,
     summary_var = "B00001_001"
    )
  
  
  
}