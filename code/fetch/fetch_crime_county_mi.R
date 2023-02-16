library(tidyverse)
library(tidycensus)
library(readxl)
library(rio)



# Get population data 

acs_df = 
  bind_rows(
  
  get_acs(geography = 'county', 
          state = 26,
          variables = 'DP05_0001', # Total population 
          year = c(2021)) %>% 
  mutate(county_name = str_squish(str_replace_all(NAME,"County, Michigan","")), 
         year = 2021) %>% 
  select(GEOID, county_name,year, pop = estimate), 

get_acs(geography = 'county', 
        state = 26,
        variables = 'DP05_0001', # Total population 
        year = c(2020)) %>% 
  mutate(county_name = str_squish(str_replace_all(NAME,"County, Michigan","")), 
         year = 2020) %>% 
  select(GEOID, county_name,year, pop = estimate)

) %>% 
mutate_all(as.character)

county_names = 
  acs_df %>% 
  select(county_name) %>% 
  distinct() %>% 
  pull()

#======================================#
# Grabbing arrests data for 2021 ====
#======================================#


url ='https://www.michigan.gov/msp/-/media/Project/Websites/msp/micr-assets/2021/Arrests-by-County-and-Agency_2021.xlsx?rev=63bbb6e69ea64fc394dc74f9bbfa212b&hash=9EC075236D8E2FAA1B489DC3AE832038'

arrests_df = rio::import(file = url, which = 2)

# Manipulate column names
col_names = 
  arrests_df %>% 
  slice(2) %>% 
  t() %>% 
  data.frame() %>% 
  filter(!is.na(.)) %>% 
  pull()

  
# Add code descriptions 

url ='https://www.michigan.gov/msp/-/media/Project/Websites/msp/micr-assets/2021/Arrests-by-County-and-Agency_2021.xlsx?rev=63bbb6e69ea64fc394dc74f9bbfa212b&hash=9EC075236D8E2FAA1B489DC3AE832038'

arrests_desc = 
  rio::import(file = url, which = 3) %>% 
  separate(col = `Offense Descriptions`,into = c('var','var_name'), sep = "-", 
           extra = 'merge') %>% 
  mutate(var = str_squish(var), 
         var_name = str_squish(var_name)) %>% 
  add_row(var = 'total',
          var_name = 'Total Arrests')


# Bringing it all together 

df_2021<-
  arrests_df

colnames(df_2021)<-c('county',col_names,'cr1','cr2','total')

df_2021<-
  df_2021 %>% 
  slice(2:nrow(arrests_df)) %>% 
  select(-cr1,-cr2) %>% 
  filter(county %in% county_names) %>% 
  mutate_all(as.character) %>% 
  pivot_longer(cols = all_of(c(col_names,'total')), names_to = 'var') %>% 
  
  left_join(arrests_desc, by = 'var') %>% 
  mutate(year = '2021')

#======================================#
# Grabbing arrests data for 2020 ====
#======================================#


url ='https://www.michigan.gov/msp/-/media/Project/Websites/msp/micr-assets/2020/arrests_by_county_and_agency.xlsx?rev=247f6fd62b7445ecae719b7800c96766&hash=3648957FA336660EA1042B69D03605F9'

arrests_df = rio::import(file = url, which = 2)

# Manipulate column names
col_names = 
  arrests_df %>% 
  slice(2) %>% 
  t() %>% 
  data.frame() %>% 
  filter(!is.na(.)) %>% 
  pull()


# Add code descriptions 

url ='https://www.michigan.gov/msp/-/media/Project/Websites/msp/micr-assets/2021/Arrests-by-County-and-Agency_2021.xlsx?rev=63bbb6e69ea64fc394dc74f9bbfa212b&hash=9EC075236D8E2FAA1B489DC3AE832038'

arrests_desc = 
  rio::import(file = url, which = 3) %>% 
  separate(col = `Offense Descriptions`,into = c('var','var_name'), sep = "-", 
           extra = 'merge') %>% 
  mutate(var = str_squish(var), 
         var_name = str_squish(var_name)) %>% 
  add_row(var = 'total',
          var_name = 'Total Arrests')


# Bringing it all together 

df_2020<-
  arrests_df

colnames(df_2020)<-c('county',col_names,'cr1','cr2','total')

df_2020<-
  df_2020 %>% 
  slice(2:nrow(arrests_df)) %>% 
  select(-cr1,-cr2) %>% 
  filter(county %in% county_names) %>% 
  mutate_all(as.character) %>% 
  pivot_longer(cols = all_of(c(col_names,'total')), names_to = 'var') %>% 
  
  left_join(arrests_desc, by = 'var') %>% 
  mutate(year = '2020')


#==========================# 
# Final Aggregations =====
#==========================# 


df<-
  bind_rows(df_2020,df_2021) %>% 
  mutate(
    num = as.numeric(value),
    var_group= case_when(substring(var,1,2)=='11'~'Rape Incidence per 10K',
                         substring(var,1,2)=='13'~'Assault Incidence per 10K',
                         substring(var,1,2)=='23'~'Larceny Incidence per 10K',
                         substring(var,1,2)=='12'~'Robbery Incidence per 10K',
                         substring(var,1,2)=='22'~'Burglary Incidence per 10K',
                         substring(var,1,2)=='to'~'Total Arrests Incidence per 10K',
                         T ~ NA_character_),
    var_num = paste0(substr(var,1,2),"xxx")
    ) %>% 
  filter(!is.na(var_group)) %>% 
  group_by(county,year,var_group,var_num) %>% 
  summarise(num = sum(num,na.rm = T)) %>% 
  ungroup() %>% 
  
  # Bring on census data to calulate rates
  
  left_join(acs_df, by = c('county'='county_name','year')) %>% 
  mutate(
    value = round((num/as.numeric(pop))*10000,2), 
    dataset = 'MICR',
    state = substr(GEOID,1,2),
    county = GEOID, 
    var = var_num, 
    var_name = var_group, 
    var_short_name = var_group,
    stat_type = 'rate')%>% 
  select(dataset,state, county, year,var,var_name,var_short_name,value,stat_type)
  
#==================================#
# Uploading to Database ====
#==================================#

# You will need to specify the exact path to the BCP utility tool 
# It will likely be very similar to this path, but you should double-check. 
options(bcputility.bcp.path = "C:/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/bcp.exe")

start<-Sys.time()

bcpImport(
  df, # The data frame you wish to upload
  # SQL Connections
  connectargs = makeConnectArgs(
    server = Sys.getenv('tbd_server_address'),
    database = 'locals',
    trustedconnection = TRUE
  ), # If TRUE, this will Windows authenticate. Be sure you are connected to the VPN. 
  table  = 'counties', # Name of the table to store the data frame you wish to upload
  overwrite = F, # Will append to the table
  bcpOptions = c('-b 50000') # This refers to the batch size of the number of rows sent at a time.Feel free to mess around with figure. This was a recommendation. 
  
)

stop <-Sys.time()
stop-start

  






