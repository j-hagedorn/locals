library(tidycensus)
library(tidyverse)
library(lubridate)
library(DBI)


#================================#
# Pulling in variable names ====
#================================#

# Use this query to scan different variable: 

census_api_key(Sys.getenv("CENSUS_API_KEY"),install = TRUE)

v <- load_variables(2020, "acs5", cache = TRUE) %>% 
  separate(label, into = paste0("label", 1:9), sep = "!!", fill = "right", remove = FALSE)

v_profile <- load_variables(2020, "acs5/profile", cache = TRUE) %>% 
  separate(label, into = paste0("label", 1:9), sep = "!!", fill = "right", remove = FALSE)

v_subject<- load_variables(2020, "acs5/subject", cache = TRUE) %>% 
  separate(label, into = paste0("label", 1:9), sep = "!!", fill = "right", remove = FALSE)


#===========================#
# ACS Data Profile ====
#===========================#

df_acs<- tibble()

for(i in 2018:2020){


profile_acs<-
  get_acs(geography = 'county'
          ,state = 'MI'
          ,variables  = c(
                           'DP02_0062P' # % 25 or over with HS diploma
                          ,'DP02_0065P' # % 25 or over with Bachelor's
                          ,'DP02_0070P' # % Veteran
                          ,'DP02_0074P' # % Children Disabled under 18
                          ,'DP02_0072P' # % Disabled total
                          ,'DP02_0094P' # % Foreign Born 
                          ,'DP03_0099P' # % no health insurance, non-inst.,18-64
                          ,'DP05_0037P' # % White 
                          ,'DP05_0038P' # % Black
                          ,'DP05_0044P' # % Asian
                          ,'DP05_0039P' # % Ntv. American or Alaskan native
                          ,'DP05_0071P' # % Hispanic or Latino 
                          ,'DP05_0035P' # % Two or more races 
                          ,'DP05_0052P' # % Pacific Islander
                          ,"DP04_0047P" # % Renter occupied homes
                          ,'DP04_0046P' # % Owner occupied homes 
                          ,"DP04_0014P" # % Mobile Homes 
                          ,'DP03_0072P' # % of households with public assistance income
                          ,'DP04_0058P' # % Occupied housing with no vehicle
                          ,'DP03_0009P' # Unemployment Rate
          )
          ,year = i
          ,show_call = F) %>% 
  left_join(v_profile, by = c('variable' = 'name')) %>% 
 # filter(GEOID == '26081') %>% 
  mutate(
    label5 = coalesce(label5,""),
    var_name = str_to_lower(paste(label1,label3,label4,label5,sep = " ")),
    dataset = 'acs_5',
    state = 26,
    county = GEOID,
    value = estimate,
    stat_type = 'frac',
    year = i) %>% 
  select(dataset,state,county,year,var_name,value,stat_type)
  
#=======================#
# Subject tables =====
#=======================#


subject_acs<-
  get_acs(geography = 'county'
          ,state = 'MI'
          ,variables  = c(
             'S2704_C03_006' # % Medicaid
            ,'S2704_C03_002' # % Medicare
            ,'S1701_C03_001' # % Poverty
          )
          ,year = i
          ,show_call = F) %>% 
  left_join(v_subject, by = c('variable' = 'name')) %>% 
#  filter(GEOID == '26081') %>% 
  mutate(
    label4 = coalesce(label4,""),
    var_name = str_to_lower(paste(label2,label4,sep = " ")),
    dataset = 'acs_5',
    state = 26,
    county = GEOID,
    value = estimate,
    stat_type = 'frac',
    year = i) %>% 
  select(dataset,state,county,year,var_name,value,stat_type)

#====================#
# ACS Variables ====
#====================#


acs_population_vars_n<-
  get_acs(geography = 'county'
          ,state = 'MI'
          ,variables  = c(
            'B01003_001', # total population 
            'B25010_001', # average household size 
            'B19013_001' #Median household income
          )
          ,year = i) %>% 
  left_join(v, by = c('variable' = 'name')) %>% 
#  filter(GEOID == '26081') %>% 
  mutate(
    label4 = coalesce(label4,""),
    var_name = case_when(variable %in% c('B01003_001') ~ "estimate total population",
                         T ~ label2),
    dataset = 'acs_5',
    state = 26,
    county = GEOID,
    value = estimate,
    stat_type = 'n',
    year = i) %>% 
  select(dataset,state,county,year,var_name,value,stat_type)




tryCatch(
expr = {
  
acs_population_vars_frac<-
  get_acs(geography = 'county'
          ,state = 'MI'
          ,variables  = c(
            'B11012_003', # total married couples family w/children households
            'B11012_010', # total single mom households
            'B25071_001'  # rent as a percent of income 
          )
          ,year = i
          ,summary_var = 'B11001_001'
          ,show_call = F) %>% 
  left_join(v, by = c('variable' = 'name')) %>% 
#  filter(GEOID == '26081') %>% 
  mutate(
    value = case_when(variable %in% c('B11012_010') ~ round((estimate/summary_est)*100,1),
                      T ~ estimate),
    label4 = coalesce(label4,""),
    label3 = coalesce(label3,label2),
    var_name = paste(label3,label4,sep = " "),
    dataset = 'acs_5',
    state = 26,
    county = GEOID,
    stat_type = 'frac',
    year = i) %>% 
  select(dataset,state,county,year,var_name,value,stat_type)

},
error = function(e)
finally = print("No data, sorry!")

)

#==================================#
# Binding all ACS Data Frames ====
#==================================#


df_acs<-
  bind_rows(df_acs,profile_acs,subject_acs,acs_population_vars_frac,acs_population_vars_n) 


}











