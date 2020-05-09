svi_county <- feather::read_feather("data/svi_county.feather")

df <-
  svi_county %>%
  select(fips,year,area_sqmi:e_daypop) %>% 
  mutate(
    state = str_sub(fips,1,2),
    county = str_sub(fips,3,5)
  ) %>%
  select(-fips) %>%
  mutate_all(list(~as.character(.))) %>%
  pivot_longer(cols = -one_of("state","county","year")) %>% 
  mutate(value = if_else(value == "-999",NA_character_,value)) %>%
  # Remove NA values for memory
  filter(!is.na(value)) %>%
  mutate(
    dataset = "svi",
    value = round(as.numeric(value),2),
    stat_type = case_when(
      str_detect(name,"^m_")   ~ "moe",
      str_detect(name,"^e_")   ~ "n",
      str_detect(name,"^mp_")  ~ "moe",
      str_detect(name,"^ep_")  ~ "frac",
      str_detect(name,"^epl_") ~ "ntile",
      str_detect(name,"^rpl_") ~ "rank",
      str_detect(name,"^f_")   ~ "flag",
      str_detect(name,"^area") ~ "n",
      TRUE ~ NA_character_
    ),
    race = "pooled",
    gender = "pooled",
    age_range = "pooled"
  ) %>%
  rename(var_name = name) %>%
  select(
    dataset,state,county,year,
    race,gender,age_range,
    var_name,value,stat_type
  ) %>%
  distinct()

# Read each separate state file and append to database
# This assumes the existence of a system DSN named 'locals', which points to a db 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")
odbc::dbWriteTable(locals_db, "counties", df, append = T)

rm(df);rm(svi_county)
