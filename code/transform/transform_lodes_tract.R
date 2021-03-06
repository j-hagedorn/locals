
library(tidyverse); library(tidycensus); library(feather)

lodes_tract <- read_feather("data/lodes_tract.feather")

df <-
  lodes_tract %>%
  rename_all(list(~str_to_lower(.))) %>%
  select(geoid = h_tract, year, c000:cns20) %>%
  mutate(
    state = str_sub(geoid,1,2),
    county = str_sub(geoid,3,5),
    tract = str_sub(geoid,6,11)
  ) %>%
  select(-geoid) %>%
  mutate_all(list(~as.character(.))) %>%
  pivot_longer(cols = -one_of("state","county","tract","year")) %>%
  group_by_at(vars(all_of(c("state","county","tract","year")))) %>%
  mutate(
    value = as.numeric(value),
    # Get total jobs as col
    total_jobs = value[name == "c000"],
    frac = value/total_jobs
  ) %>%
  rename(var_name = name) %>%
  select(-total_jobs) %>%
  ungroup() %>%
  pivot_longer(cols = -one_of("state","county","tract","year","var_name")) %>%
  mutate(
    stat_type = case_when(
      name == "value" ~ "n",
      name == "frac"  ~ "frac",
      TRUE ~ NA_character_
    ),
    race = "pooled",
    gender = "pooled",
    age_range = "pooled",
    var_name = paste0(var_name,"_",stat_type),
    dataset = "lodes_rac",
    value = round(as.numeric(value),2)
  ) %>%
  # Remove NA values for memory
  filter(!is.na(value)) %>%
  filter(var_name != "c000_frac") %>%
  select(
    dataset,state,county,tract,year,
    race,gender,age_range,
    var_name,value,stat_type
  ) %>%
  distinct()

# Read each separate state file and append to database
# This assumes the existence of a system DSN named 'locals', which points to a db 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")
odbc::dbWriteTable(locals_db, "tracts", df, append = T)

rm(df); rm(lodes_tract)
