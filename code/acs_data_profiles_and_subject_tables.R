library(tidycensus)
library(tidyverse)
library(lubridate)
library(DBI)
library(xlsx)
library(data.table)
library(bcputility)


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

profile_acs_variables <-
c(
  'DP05_0001' # Total population 
  ,'DP02_0062P' # % 25 or over with HS diploma
  ,'DP02_0062'
  ,'DP02_0065P' # % 25 or over with Bachelor's
  ,'DP02_0065'
  ,'DP02_0070P' # % Veteran
  ,'DP02_0070'
  ,'DP02_0074P' # % Children Disabled under 18
  ,'DP02_0074'
  ,'DP02_0072P' # % Disabled total
  ,'DP02_0072P'
  ,'DP02_0094P' # % Foreign Born 
  ,'DP02_0094P'
  ,'DP03_0099P' # % no health insurance, non-inst.,18-64
  ,'DP03_0099P'
  ,'DP05_0037P' # % White 
  ,'DP05_0037'
  ,'DP05_0038P' # % Black
  ,'DP05_0038'
  ,'DP05_0044P' # % Asian
  ,'DP05_0044'
  ,'DP05_0039P' # % Ntv. American or Alaskan native
  ,'DP05_0039'
  ,'DP05_0071P' # % Hispanic or Latino 
  ,'DP05_0071'
  ,'DP05_0035P' # % Two or more races 
  ,'DP05_0035' 
  ,'DP05_0052P' # % Pacific Islander
  ,'DP05_0052'
  ,"DP04_0047P" # % Renter occupied homes
  ,"DP04_0047"
  ,'DP04_0046P' # % Owner occupied homes 
  ,'DP04_0046'
  ,"DP04_0014P" # % Mobile Homes 
  ,"DP04_0014" 
  ,'DP03_0072P' # % of households with public assistance income
  ,'DP03_0072'
  ,'DP04_0058P' # % Occupied housing with no vehicle
  ,'DP04_0058'
  ,'DP03_0009P' # Unemployment Rate
  ,'DP03_0009'
  ,'DP02_0045P' # % Grandparents responsible for grandchildren
  ,'DP02_0045'
  ,'DP03_0062'  # Median Household Income 
  ,'DP03_0047P' # % Private salary or wage earners
  ,'DP03_0047'
  ,'DP03_0049P' # % Self employed worker
  ,'DP03_0049'
  ,'DP03_0048P' # % Goverment Worker
  ,'DP03_0048'
)

#================================#
# ACS Data Counties Profile ====
#================================#

profile_acs<-
  get_acs(geography = 'county'
          #  ,state = 'MI'
          ,variables = profile_acs_variables  
          ,year = 2020
          ,show_call = F) %>% 
  left_join(v_profile, by = c('variable' = 'name')) %>% 
  mutate_all(as.character)

profile_acs[is.na(profile_acs)]<-""

profile_acs<-
  profile_acs %>% 
  mutate(
    label5 = coalesce(label5,""),
    var_name = str_to_lower(paste(label1,label3,label4,label5,sep = " ")),
    dataset = 'acs_5',
    state = substr(GEOID,1,2),
    county = GEOID,
    value = estimate,
    stat_type = case_when(label1 == "Percent" ~ 'frac',
                          T ~ 'n'),
    year = 2020) %>% 
  select(dataset,state,county,year,var_name,value,stat_type) %>% 
  mutate_all(as.character)

#=======================#
# Subject tables =====
#=======================#

subject_acs<-
  get_acs(geography = 'county'
          #   ,state = 'MI'
          ,variables  = c(
            'S2704_C03_006' # % Medicaid
            ,'S2704_C03_002' # % Medicare
            ,'S1701_C03_001' # % Poverty
          )
          ,year = 2020
          ,show_call = F) %>% 
  left_join(v_subject, by = c('variable' = 'name')) %>% 
  mutate(
    label4 = coalesce(label4,""),
    var_name = str_to_lower(paste(label2,label4,sep = " ")),
    dataset = 'acs_5',
    state = substr(GEOID,1,2),
    county = GEOID,
    value = estimate,
    stat_type = 'frac',
    year = 2020) %>% 
  select(dataset,state,county,year,var_name,value,stat_type) %>% 
  mutate_all(as.character)



#==================================#
# Uploading to Database ====
#==================================#

df_acs<-
  bind_rows(profile_acs,subject_acs) %>% 
  mutate(value = case_when(str_count(value)==0 ~ NA_character_,
                            T ~ value))



# You will need to specify the exact path to the BCP utility tool 
# It will likely be very similar to this path, but you should double-check. 
options(bcputility.bcp.path = "C:/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/bcp.exe")

start<-Sys.time()

bcpImport(
  df_acs, # The data frame you wish to upload
  trustedconnection = TRUE, # If TRUE, this will Windows authenticate. Be sure you are connected to the VPN. 
  driver = "ODBC Driver 17 for SQL Server",
  server = Sys.getenv('SERVER'),
  database = 'locals',
  table  = 'counties', # Name of the table to store the data frame you wish to upload
  batchsize = 50000, # Feel free to mess around with figure. This was a recommendation. 
  overwrite = T, # Will overwrite the table or create a table if one dosen't exist
  
)

stop <-Sys.time()
stop-start



#================================#
# ACS Data Tract Profile ====
#================================#

state_list =  unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])


profile_acs<-
  get_acs(geography = 'tract'
          ,state = state_list
         # ,state = 'mi'
          ,variables = profile_acs_variables
          ,year = 2020
          ,show_call = F) %>% 
  left_join(v_profile, by = c('variable' = 'name')) %>% 
  mutate_all(as.character)

profile_acs[is.na(profile_acs)]<-""

profile_acs<-
  profile_acs %>% 
  mutate(
    label5 = coalesce(label5,""),
    var_name = str_to_lower(paste(label1,label3,label4,label5,sep = " ")),
    dataset = 'acs_5',
    state = substr(GEOID,1,2),
    county = substr(GEOID,1,5),
    tract = GEOID,
    value = estimate,
    stat_type = case_when(label1 == "Percent" ~ 'frac',
                          T ~ 'n'),
    year = 2020) %>% 
  select(dataset,state,county,tract,year,var_name,value,stat_type) %>% 
  mutate_all(as.character)

#=======================#
# Subject tables =====
#=======================#

subject_acs<-
  get_acs(geography = 'tract'
         # ,state = state_list
          , state = 'mi'
          ,variables  = c(
            'S2704_C03_006' # % Medicaid
            ,'S2704_C03_002' # % Medicare
            ,'S1701_C03_001' # % Poverty
          )
          ,year = 2020
          ,show_call = F) %>% 
  left_join(v_subject, by = c('variable' = 'name')) %>% 
  mutate(
    label4 = coalesce(label4,""),
    var_name = str_to_lower(paste(label2,label4,sep = " ")),
    dataset = 'acs_5',
    state = substr(GEOID,1,2),
    county = substr(GEOID,1,5),
    tract = GEOID,
    value = estimate,
    stat_type = 'frac',
    year = 2020) %>% 
  select(dataset,state,county,tract,year,var_name,value,stat_type) %>% 
  mutate_all(as.character)



#==================================#
# Uploading to Database ====
#==================================#

df_acs<-
  bind_rows(profile_acs,subject_acs)  %>% 
  mutate(value = case_when(str_count(value)==0 ~ NA_character_,
                           T ~ value))

# You will need to specify the exact path to the BCP utility tool 
# It will likely be very similar to this path, but you should double-check. 
options(bcputility.bcp.path = "C:/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/bcp.exe")

start<-Sys.time()

bcpImport(
  df_acs, # The data frame you wish to upload
  trustedconnection = TRUE, # If TRUE, this will Windows authenticate. Be sure you are connected to the VPN. 
  driver = "ODBC Driver 17 for SQL Server",
  server = Sys.getenv('SERVER'),
  database = 'locals',
  table  = 'tracts', # Name of the table to store the data frame you wish to upload
  batchsize = 50000, # Feel free to mess around with figure. This was a recommendation. 
  overwrite = T, # Will overwrite the table or create a table if one dosen't exist
  
)

stop <-Sys.time()
stop-start

rm(stop,start,state_list,profile_acs_variables,v_subject,v_profile,v,test,df_acs,
   profile_acs,subject_acs)
