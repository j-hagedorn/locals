## transform_covid_projections.R

library(tidyverse)

source("code/fetch/fetch_covid_projections.R")

projection_5mobility <- projection_5mobility %>%
  rename(date = Date) %>%
  mutate(date = as.Date(date, format = "%m/%d/%y"))

projection_50transmissibility <- projection_50transmissibility %>%
  rename(date = Date) %>%
  mutate(date = as.Date(date, format = "%m/%d/%y"))

projection_75transmissibility <- projection_75transmissibility %>%
  rename(date = Date) %>%
  mutate(date = as.Date(date, format = "%m/%d/%y"))

projection_nointervention <- projection_nointervention %>%
  rename(date = Date) %>%
  mutate(date = as.Date(date, format = "%m/%d/%y"))