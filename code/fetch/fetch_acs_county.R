
# First run ACS tract data to get lookup vars
# source("code/fetch/fetch_acs_tract.R")

acs5_county <- tibble()

for (i in unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])) {
  
  df <- 
    get_acs(
      geography = "county", 
      variables = acs_vars$name, 
      state = i, 
      year = max(year_range)
    ) %>%
    group_by(GEOID) %>%
    mutate(
      # Get total pop as col
      pop = estimate[variable == "B00001_001"],
      frac = estimate/pop,
      year = max(year_range)
    ) %>%
    filter(variable != "B00001_001") %>%
    left_join(acs_vars, by = c("variable" = "name"))
  
  acs5_county <- bind_rows(acs5_county,df)
  
}

write_feather(acs5_county,"data/acs5_county.feather")
