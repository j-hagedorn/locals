source("..code/connect/read_odbc.R")

exercise_data <-
  counties_db %>% 
  filter(state == "06") %>%
  filter(year == "2019") %>%
  filter_at(vars(race,gender,age_range), all_vars(. == "pooled")) %>%
  select(state,county,year,var_name,value) %>%
  collect() %>%
  distinct(state,county,year,var_name, .keep_all = T) %>%
  group_by(state,county,year) %>%
  pivot_wider(names_from = var_name, values_from = value) %>%
  select(-`NA`) %>%
  write_csv("data/exercise_data.csv")

county_lookup <- 
  fips %>% 
  group_by(state_id,name_state,county_id,name_county,pop_county,sqmi_county) %>% 
  summarize() %>%
  write_csv("data/county_lookup.csv")
