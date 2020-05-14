
evict_tract <- fetch_evictions_tract()

df <-
  evict_tract %>%
  rename_all(list(~str_to_lower(.))) %>%
  rename_all(list(~str_replace_all(.,"-","_"))) %>%
  # Remove race, which is not a breakdown of evictions
  select(-pct_white:-pct_other) %>%
  select(geoid,year,renter_occupied_households:subbed) %>% 
  mutate(
    state = str_sub(geoid,1,2),
    county = str_sub(geoid,3,5),
    tract = str_sub(geoid,6,11)
  ) %>%
  select(
    -geoid,-median_gross_rent, -median_household_income,
    -median_property_value
  ) %>%
  pivot_longer(cols = -one_of("state","county","tract","year")) %>%
  mutate(
    dataset = "evict",
    value = round(as.numeric(value),2),
    stat_type = case_when(
      str_detect(name,"^median_")    ~ "median",
      str_detect(name,"rent_burden") ~ "median",
      str_detect(name,"rate$")       ~ "frac",
      str_detect(name,"^pct_")       ~ "frac",
      str_detect(name,"households$|evictions$|filings$") ~ "n",
      str_detect(name,"flag$|imputed$|subbed$") ~ "flag",
      TRUE ~ NA_character_
    ),
    race = "pooled",
    gender = "pooled",
    age_range = "pooled"
  ) %>%
  rename(var_name = name) %>%
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

rm(df); rm(evict_tract)
