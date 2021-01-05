library(tidycensus)
library(tidyverse)
library(lubridate)
library(DBI)


# The script is intended to pull variables from the census api and store in our database 


census_api_key('2e813467b85f18e31859f48cefdd60a3ef4aa81e')

census_dic<-read_csv("data/census_var_dic.csv")


acs_vars_by_year<-c(
  'B01003_001', # total population 
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
  'B23025_002', # total labor force 
  'B23025_005', # total employed 
  'B23007_007', # total two parent working households with children 
  'B23007_009', # total two parent households with stay-at-home mom
  'B19057_002', # total receiving public assistance income last 12 months 
  'B08301_010', # total taking public transportation to work
  'B19053_002', # total receiving self-employment income
  'B08128_003', # total private company workers 
  'B08128_005', # total non-profit workers 
  'B08128_004', # total self employed worker 
  'B08128_006', # total local government worker 
  'B08128_007', # total state government worker 
  'B08128_008', # total federal government worker 
  'B08128_009', # total self-employed contractors 
  'B08128_010', # total unpaid-family workers (children or family helping business)
  'B11001_001', # total households including living alone 
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
  'B19013_001', # median household income (inflation adjusted)
  'B25004_008'  # Other vacant housing units (includes vacant housing such as abandoned,needs repair and others see : https://www.census.gov/housing/hvs/definitions.pdf#:~:text=A%20housing%20unit%20is%20vacant%20if%20no%20one,a%20usual%20residence%20elsewhere.%20New%20units%20not%20yet)
  
)


#================#
# Table creation 
#================#


# Looping over the census api for each variable stated above for each year and 
# for every state and storing in the acs5_county tibble 



acs5_county <- tibble()

year_range<-2010:year(today())


#for (st in unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])) {
  
for (v in acs_vars_by_year){ 
   
  for( y in year_range){
    
    tryCatch(
  
      expr = {
  df <- 
    get_acs(
      geography = "county", 
      variables = v,
      state = 'MI' , # i
      year = y
    ) %>%
    mutate( year = y)

  
  acs5_county <- bind_rows(acs5_county,df)
  
      }, 
  error =  function(e){})
  
  }
}
 

# manipulating the results and adding the variable names from the data dictionary. 
# The data dictionary should be updated with any new variables before joining. 

df<-acs5_county %>%
  left_join(census_dic, by = c("variable" = 'var_num')) %>%
  mutate(
    dataset = 'acs_5',
    state = substr(GEOID, 1,2),
    county = GEOID, 
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
        str_detect(var_name,'over65') ~ 'over65',
        str_detect(var_name,'35to64') ~ '35to64',
        str_detect(var_name,'19to64') ~ '19to64',
        str_detect(var_name,'19to34') ~ '19to34',
        str_detect(var_name,'under19') ~'under19',
        TRUE ~ "pooled"
      ),
    stat_type = case_when(
      str_detect(var_name,"pop|labor|homes") ~ 'n',
                 TRUE ~ 'frac')
  ) %>%
  select(
    dataset,state,county,year,race,gender,age_range,var_name,value,stat_type
  )
  
  
df%>%
  filter(county == '26163')%>%
  filter(var_name == 'self_employed_worker_labor')%>%
  select(year,value)%>%
  ggplot(aes(x = year, y = value)) + geom_point()+geom_line()
  


#=============================#
# push to database ====
#=============================#

# Connect to DB
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")


# create sql query to delete the old data and insert the new
vars<-census_dic%>%
  select(var_name)%>%
  distinct()%>%
  pull()


vars_sql<- noquote(paste("'",as.character(vars),"'",collapse=", ",sep=""))


delete_query<-
{paste("
        delete
        FROM [dbo].[counties]
        where var_name in (",vars_sql,") ",sep = "")
               
 }


dbSendQuery(locals_db,delete_query)

# Writing updated or new variables to databasae 
odbc::dbWriteTable(locals_db, 'counties', df, append = T)
  
  
  
