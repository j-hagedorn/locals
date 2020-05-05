## transform_covid_projections.R

library(tidyverse)

source("code/fetch/fetch_covid_projections.R")

source("code/fetch/fetch_fips.R")

# Projection_5%mobility

projection_5mobility <- projection_5mobility %>%
  rename(date = Date) %>%
  pivot_longer(
    cols = c(report_median, report_2.5, report_25, report_75, report_97.5,
             total_median, total_2.5, total_25, total_75, total_97.5),
    names_to = "var_name"
  ) %>%
  mutate(
    dataset = 'Project_5%mobility',
    date = as.Date(date, format = "%m/%d/%y"),
    stat_type = case_when(
      var_name == "report_median" ~ "median",
      var_name == "report_2.5"    ~ "95% CI",   
      var_name == "report_25"     ~ "p25",     
      var_name == "report_75"     ~ "p75",     
      var_name == "report_97.5"   ~ "95% CI",   
      var_name == "total_median"  ~ "median",  
      var_name == "total_2.5"     ~ "95% CI",    
      var_name == "total_25"      ~ "p25",      
      var_name == "total_75"      ~ "p75",      
      var_name == "total_97.5"    ~ "95% CI"
    )
  ) %>%
  left_join(
    all_fips %>%
      filter(`County Subdivision Code (FIPS)` == "00000") %>%
      select(`State Code (FIPS)`, `County Code (FIPS)`, 
             `Area Name (including legal/statistical area description)`, county_state_fips), 
    by = c("fips" = "county_state_fips")
  ) %>%
  select(-county) %>%
  left_join(
    state_fips %>%
      select(`State (FIPS)`, Name,), by = c("State Code (FIPS)" = "State (FIPS)")
  ) %>%
  rename(
    state = Name,
    county = `Area Name (including legal/statistical area description)`,
  ) %>%
  select(dataset, state, county, fips, date, var_name, value, stat_type)

odbc::dbWriteTable(locals_db, "covid", projection_5mobility, append = T)


# Projection_50%transmissibility
projection_50transmissibility <- projection_50transmissibility %>%
  rename(date = Date) %>%
  pivot_longer(
    cols = c(report_median, report_2.5, report_25, report_75, report_97.5,
             total_median, total_2.5, total_25, total_75, total_97.5),
    names_to = "var_name"
  ) %>%
  mutate(
    dataset = 'Project_50%transmissibility',
    date = as.Date(date, format = "%m/%d/%y"),
    stat_type = case_when(
      var_name == "report_median" ~ "median",
      var_name == "report_2.5"    ~ "95% CI",   
      var_name == "report_25"     ~ "p25",     
      var_name == "report_75"     ~ "p75",     
      var_name == "report_97.5"   ~ "95% CI",   
      var_name == "total_median"  ~ "median",  
      var_name == "total_2.5"     ~ "95% CI",    
      var_name == "total_25"      ~ "p25",      
      var_name == "total_75"      ~ "p75",      
      var_name == "total_97.5"    ~ "95% CI"
    )
  ) %>%
  left_join(
    all_fips %>%
      filter(`County Subdivision Code (FIPS)` == "00000") %>%
      select(`State Code (FIPS)`, `County Code (FIPS)`, 
             `Area Name (including legal/statistical area description)`, county_state_fips), 
    by = c("fips" = "county_state_fips")
  ) %>%
  select(-county) %>%
  left_join(
    state_fips %>%
      select(`State (FIPS)`, Name), by = c("State Code (FIPS)" = "State (FIPS)")
  ) %>%
  rename(
    state = Name,
    county = `Area Name (including legal/statistical area description)`
  ) %>%
  select(dataset, state, county, fips, date, var_name, value, stat_type)

odbc::dbWriteTable(locals_db, "covid", projection_50transmissibility, append = T)


# Projection_75%transmissibility

projection_75transmissibility <- projection_75transmissibility %>%
  rename(date = Date) %>%
  pivot_longer(
    cols = c(report_median, report_2.5, report_25, report_75, report_97.5,
             total_median, total_2.5, total_25, total_75, total_97.5),
    names_to = "var_name"
  ) %>%
  mutate(
    dataset = 'Project_75%transmissibility',
    date = as.Date(date, format = "%m/%d/%y"),
    stat_type = case_when(
      var_name == "report_median" ~ "median",
      var_name == "report_2.5"    ~ "95% CI",   
      var_name == "report_25"     ~ "p25",     
      var_name == "report_75"     ~ "p75",     
      var_name == "report_97.5"   ~ "95% CI",   
      var_name == "total_median"  ~ "median",  
      var_name == "total_2.5"     ~ "95% CI",    
      var_name == "total_25"      ~ "p25",      
      var_name == "total_75"      ~ "p75",      
      var_name == "total_97.5"    ~ "95% CI"
    )
  ) %>%
  left_join(
    all_fips %>%
      filter(`County Subdivision Code (FIPS)` == "00000") %>%
      select(`State Code (FIPS)`, `County Code (FIPS)`, 
             `Area Name (including legal/statistical area description)`, county_state_fips), 
    by = c("fips" = "county_state_fips")
  ) %>%
  select(-county) %>%
  left_join(
    state_fips %>%
      select(`State (FIPS)`, Name), by = c("State Code (FIPS)" = "State (FIPS)")
  ) %>%
  rename(
    state = Name,
    county = `Area Name (including legal/statistical area description)`
  ) %>%
  select(dataset, state, county, fips, date, var_name, value, stat_type)

odbc::dbWriteTable(locals_db, "covid", projection_75transmissibility, append = T)

# Projection_nointervention
projection_nointervention <- projection_nointervention %>%
  rename(date = Date) %>%
  pivot_longer(
    cols = c(report_median, report_2.5, report_25, report_75, report_97.5,
             total_median, total_2.5, total_25, total_75, total_97.5),
    names_to = "var_name"
  ) %>%
  mutate(
    dataset = 'Project_nointervention',
    date = as.Date(date, format = "%m/%d/%y"),
    stat_type = case_when(
      var_name == "report_median" ~ "median",
      var_name == "report_2.5"    ~ "95% CI",   
      var_name == "report_25"     ~ "p25",     
      var_name == "report_75"     ~ "p75",     
      var_name == "report_97.5"   ~ "95% CI",   
      var_name == "total_median"  ~ "median",  
      var_name == "total_2.5"     ~ "95% CI",    
      var_name == "total_25"      ~ "p25",      
      var_name == "total_75"      ~ "p75",      
      var_name == "total_97.5"    ~ "95% CI"
    )
  ) %>%
  left_join(
    all_fips %>%
      filter(`County Subdivision Code (FIPS)` == "00000") %>%
      select(`State Code (FIPS)`, `County Code (FIPS)`, 
             `Area Name (including legal/statistical area description)`, county_state_fips), 
    by = c("fips" = "county_state_fips")
  ) %>%
  select(-county) %>%
  left_join(
    state_fips %>%
      select(`State (FIPS)`, Name), by = c("State Code (FIPS)" = "State (FIPS)")
  ) %>%
  rename(
    state = Name,
    county = `Area Name (including legal/statistical area description)`
  ) %>%
  select(dataset, state, county, fips, date, var_name, value, stat_type)

odbc::dbWriteTable(locals_db, "covid", projection_nointervention, append = T)

rm(all_fips); rm(state_fips)
rm(projection_5mobility); rm(projection_50transmissibility);
rm(projection_75transmissibility); rm(projection_nointervention)

