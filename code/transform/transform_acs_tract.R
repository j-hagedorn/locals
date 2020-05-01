
# Transform  data
acs5_tract <- feather::read_feather("data/acs5_tract.feather")
memory.limit(60000)

df <-
  acs5_tract %>% 
  mutate(
    state = str_sub(GEOID,1,2),
    county = str_sub(GEOID,3,5),
    tract = str_sub(GEOID,6,11)
  ) %>%
  select(
    state,county,tract,var_name,year,
    race,gender,age_range,
    estimate,moe,frac
  ) %>%
  mutate(
    # Set frac to NA if measure is median
    frac = if_else(str_detect(var_name,"median"),NA_real_,frac)
  ) %>%
  pivot_longer(
    cols = -one_of(
      "state","county","tract","var_name","year","race","gender","age_range"
    )
  ) %>% 
  # Remove NA values for memory
  filter(!is.na(value)) %>%
  mutate(
    dataset = "acs_5",
    value = round(value,2),
    stat_type = case_when(
      str_detect(var_name,"median") ~ "median",
      str_detect(name,"estimate")   ~ "n",
      str_detect(name,"moe")        ~ "moe",
      str_detect(name,"frac")       ~ "frac",
      TRUE ~ NA_character_
    ),
    var_name = paste0(var_name,"_",stat_type)
  ) %>%
  select(
    dataset,state,county,tract,year,
    race,gender,age_range,
    var_name,value,stat_type
  ) %>%
  distinct()

# To do:
# Deal with multiple overlapping age range options
# Combine race categories 

# This assumes the existence of a system DSN named 'locals', which points to a db 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")
odbc::dbWriteTable(locals_db, "tracts", df, append = T)

rm(acs5_tract); rm(df)