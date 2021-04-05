library(tidycensus)
library(tidyverse)
library(lubridate)
library(DBI)

#======================#
# Introduction ====
#======================#

# The script is intended to pull variables from the census api and store in our database. 
# Any variable needs to be explicitly named and documented in the data_dictionary CSV
# as well as in the code below. In general, the naming convention takes the following form: 

# variable_by_group_universe

# Where:
# variable is the name of the measure (medicaid)
# by group is any subset of the variable (medicaid_under65)
# universe is the grain at which the variable is taken (medicaid_under65_pop)

# For example, the variable B11012 looks at female householders with no spouse or parent 
# but with their own children 18 and under; basically single mother households. 

# The variable would be single householders,the by-group is mothers and the universe the number of homes.
# Therefore the variable name is named: 

# single_mom_homes



# Use this query to scan different variable: 

census_api_key(Sys.getenv("CENSUS_API_KEY"))


v <- load_variables(2019, "acs5", cache = TRUE)

census<-v%>%
  # filter(str_detect(concept,'median')==T)%>%
  #filter(str_detect(concept,'health')==T)%>%
  filter(str_detect(label,'Income')==T)%>%
  filter(str_detect(label,"Median")==T)


#======================================#
# Variable List & Data Dictionary  ==== 
#======================================#

census_dic<-read_csv('docs/data_dictionary.csv')  %>%
  filter(dataset =='acs_5',
         !is.na(var_num))


acs_vars_by_year<-c(
  'B01003_001', # total population 
  'B11001_001', # total homes 
  'B23025_002', # total labor force 
  'B06012_002', # total below poverty 
  'B02001_003', # total African-American 
  'B02001_002', # total White 
  'B03001_003', # total Latino
  'B02001_005', # total Asian
  'B11012_015', # total single dad households 
  'B11012_010', # total single mom households 
  'B25071_001', # rent as a percent of income 
  'B25012_010', # total renter occupied homes 
  'B25012_002', # total owner occupied homes 
  'B11001_003', # total married couples family 
  'B25010_001', # average household size 
  'B10002_002', # total grandparent households responsible for own grandchildren
  'B06009_003', # total high school graduates (including equivalency)
  'B06009_004', # total some college or associates degree
  'B06009_005', # total bachelor's degree 
  'B06009_006', # total graduate or professional degree 
  'B06009_007', # total born in state of residence
  'B21001_002', # total veteran 
  'B07001_066', # total moved from different state in the last 1-4 years 
  'B07001_065', # total moved from different state 
  'B05002_013', # total foreign born 
  'B23025_007', # total not in the labor force 
  'B23025_005', # total employed 
  'B23007_007', # total two parent working households with children 
  'B23007_009', # total two parent households with stay-at-home mom
  'B19057_002', # total receiving public assistance income last 12 months 
  'B08301_010', # total taking public transportation to work
  'B19053_002', # total receiving self-employment income
  'B08128_003', # total private company workers 
  'B08128_005', # total non-profit workers 
  'B08128_006', # total local government worker 
  'B08128_007', # total state government worker 
  'B08128_008', # total federal government worker 
  'B08128_009', # total self-employed contractors 
  'B08128_010', # total unpaid-family workers (children or family helping business)
  'C27006_004', # total medicare coverage for males under 19
  'C27006_007', # total medicare coverage for males 19 to 64
  'C27006_010', # total medicare coverage for males 65 and over 
  'C27006_014', # total medicare coverage for females under 19
  'C27006_017', # total medicare coverage for females 19 to 64
  'C27006_020', # total medicare coverage for females 65 and over
  'C27007_004', # total medicaid coverage for males under 19
  'C27007_007', # total medicaid coverage for males 19 to 64
  'C27007_010', # total medicaid coverage for males 65 and over 
  'C27007_014', # total medicaid coverage for females under 19
  'C27007_017', # total medicaid coverage for females 19 to 64
  'C27007_020', # total medicaid coverage for females 65 and over 
  'B27010_017', # total no health insurance under 19
  'B27010_033', # total no health insurance 19 to 34
  'B27010_050', # total no health insurance 35 to 64
  'B27010_066', # total no health insurance 65 and over 
  'B25024_010', # total mobile home units 
  'B25024_007', # total housing with units between 10 and 19
  'B25024_008', # total housing with units 20 and over 
  
  'B18101_004', #Total males with a disability under 5
  'B18101_007', #Total males with a disability between 5 and 17
  'B18101_010', #Total males with a disability between 18 and 34
  'B18101_013', #Total males with a disability between 35 and 64
  'B18101_016', #Total males with a disability between 65 and 74
  'B18101_019', #Total males with a disability 75 and over
  
  'B18101_023', #Total females with a disability under 5
  'B18101_026', #Total females with a disability between 5 and 17
  'B18101_029', #Total females with a disability between 18 and 34
  'B18101_032', #Total females with a disability between 35 and 64
  'B18101_035', #Total females with a disability between 65 and 74
  'B18101_038', #Total females with a disability 75 and over
  
  'B19013_001', #Median household income
  'B25004_008', #Other vacant housing units (includes foreclosures/abandoned)
  'B08128_004'  #Total self employed worker
  
)

#==========================#
# Census Table Pull ====
#==========================#


# Looping over the census api for each variable stated above for each year and 
# for every state and storing in the acs5_tract tibble 


acs5_tract <- tibble()

# use when getting data longitudinal 
year_range<-2010:year(today())


for (st in unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])) {
  
  for (v in acs_vars_by_year){ 
    
    # for( y in year_range){ 
    
    tryCatch(
      
      expr = {
        df <- 
          get_acs(
            geography = "tract", 
            variables = v, # Variable list
            state = st , # State list
            year = 2019 
          ) %>%
          mutate( year = "2019")
        
        
        acs5_tract <- bind_rows(acs5_tract,df)
        
      }, 
      error =  function(e){})
    
    #  } Year loop
  }
}


# manipulating the results and adding the variable names from the data dictionary. 
# The data dictionary should be updated with any new variables before joining. 

df<-acs5_tract %>%
  left_join(census_dic, by = c("variable" = 'var_num')) %>%
  mutate(
    dataset = 'acs_5',
    state = substr(GEOID, 1,2),
    county = substr(GEOID, 1,5), 
    tract = GEOID,
    value = estimate,
    race = case_when(
      str_detect(var_name,'latino') ~ "hispanic",
      str_detect(var_name,'african') ~ "black",
      str_detect(var_name,'white')~ "white",
      str_detect(var_name,'asian')~ "asian",
      TRUE ~ "pooled"
    ),
    gender = case_when(
      str_detect(var_name,"female") ~ "female",
      str_detect(var_name,"male") ~ "male",
      TRUE ~ "pooled"
    ),
    age_range = case_when(
      str_detect(var_name,'75over') ~ '75over',
      str_detect(var_name,'65to74') ~ '65to74',
      str_detect(var_name,'65over') ~ '65over',
      str_detect(var_name,'35to64') ~ '35to64',
      str_detect(var_name,'19to64') ~ '19to64',
      str_detect(var_name,'18to34') ~ '18to34',
      str_detect(var_name,'19to34') ~ '19to34',
      str_detect(var_name,'5to17') ~ '5to17',
      str_detect(var_name,'under19') ~'under19',
      str_detect(var_name,'under5') ~ 'under5',
      TRUE ~ "pooled"
    ),
    stat_type = case_when(
      str_detect(var_name,"pop|labor|homes") ~ 'n',
      TRUE ~ 'frac')
  ) %>%
  select(
    dataset,state,county,tract,year,race,gender,age_range,var_name,value,stat_type
  ) %>%
  distinct()



#test<-df %>%
#  filter(age_range == 'pooled') %>%
#  select(var_name) %>%
#  distinct()



#==========================#
# Insert into database ====
#==========================#

# Connect to DB
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")


# create sql query to delete the old data and insert the new
vars<-
  read_csv('docs/data_dictionary.csv')  %>%
  filter(dataset =='acs_5') %>%
  select(var_name)%>%
  distinct()%>%
  pull()

vars_sql<- noquote(paste("'",as.character(vars),"'",collapse=", ",sep=""))


delete_query<-
  {paste("
        delete
        FROM [dbo].[tracts]
        where var_name in (",vars_sql,") ",sep = "")
    
  }


dbSendQuery(locals_db,delete_query)


start<-Sys.time()
# Writing updated or new variables to data base 
odbc::dbWriteTable(locals_db, 'tracts', df, append = T)

end<-Sys.time()
