library(tidycensus)
library(tidyverse)
library(lubridate)
library(sf)
 


standard_name_format = function(x){
  
  x<- str_squish(x)
  x<- str_replace_all(x," ","_")
  x<- str_to_lower(x)
  x<- str_replace_all(x,"_na","")
  x
}

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

v_frac<-
  v_profile %>% 
  filter(label1=='Percent') 



profile_acs_variables <-
  c(
    'DP05_0001' # Total population 
    # Education 
    ,'DP02_0061P' # % 9-12th grade, no diploma
    ,'DP02_0062P' # % 25 or over with HS diploma
    ,'DP02PR_0063P' # % some college, no degree
    ,'DP02PR_0068P' # % 25 or over with Bachelor's or higher
    
    # Employment 
    ,'DP03_0009P' # % Unemployment Rate
    ,'DP03_0002P' # % in the labor force
    
    # Household char
    ,'DP02_0003P' # % married household with kids under 18
    ,'DP03_0126P' # % Single mother families 
    
    #Housing 
    ,'DP04_0142P' # % of households spending 35% or more of thier income on rent
    ,"DP04_0047P" # % Renter occupied homes
    ,'DP04_0046P' # % Owner occupied homes 
    ,"DP04_0014P" # % Mobile Homes 
    ,'DP04_0058P' # % Occupied housing with no vehicle
    ,'DP04_0003P' # % vacant housing 
    ,'DP04_0005P' # % Rental vacancey rate 
    
    # Health Care 
    ,'DP02_0074P' # % Children Disabled under 18
    ,'DP03_0099P' # % no health insurance, non-inst.,18-64
    ,'DP03_0098P' # % public coverage 
    ,'DP02_0072P' # % Disabled total
    # Social Demographics 
    ,'DP02_0070P' # % Veteran
    ,'DP02_0094P' # % Foreign Born 
    ,'DP05_0037P' # % White 
    ,'DP05_0038P' # % Black
    ,'DP05_0044P' # % Asian
    ,'DP05_0039P' # % Ntv. American or Alaskan native
    ,'DP05_0071P' # % Hispanic or Latino 
    ,'DP05_0035P' # % Two or more races 
    ,'DP05_0052P' # % Pacific Islander
    ,'DP02_0036P' # % female Divorce Rate
    # Economic 
    ,'DP03_0072P' # % of households with public assistance income
    ,'DP03_0062'  # Median Household Income 
    
  )

industry_type<-
  v_profile %>% 
  filter(label1=='Percent',
         label2 %in% c('INDUSTRY','OCCUPATION'), 
         !name %in% c('DP03_0032P','DP03_0026P')) %>% 
  select(name) %>% 
  distinct() %>% pull()

profile_acs_variables = c(profile_acs_variables, industry_type) %>% unique() 



#================================#
# ACS Data Counties Profile ====
#================================#


# Profile ACS Variables 

profile_acs<-tibble()

for (st in unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])) {
  
  
  iter_x<-
    get_acs(geography = 'tract'
            ,state = st
            ,variables = profile_acs_variables  
            ,year = 2020
            ,show_call = F) %>% 
    left_join(v_profile, by = c('variable' = 'name')) %>% 
    mutate_all(as.character)
  
  
  profile_acs<-bind_rows(profile_acs, iter_x)
  
}


profile_acs<-
  profile_acs %>% 
  mutate(
    label5 = coalesce(label5,""),
    var_name = str_to_lower(paste(label1,label3,label4,label5,sep = " ")),
    tract = GEOID,
    value = estimate) %>% 
  select(variable,tract,var_name,value) %>% 
  mutate_all(as.character) %>% 
  # Remove empty variables 
  mutate(var_check = ifelse(is.na(value),0,1)) %>% 
  group_by(var_name,variable) %>% 
  mutate(sum_check = sum(var_check,na.rm = T)) %>% 
  ungroup() %>% 
  filter(sum_check >0)  %>% 
  select(-var_check,-sum_check) %>% 
  distinct()


# Subject ACS Variables 

subject_acs<-tibble()

for (st in unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])) {
  
  
  iter_x<-
    get_acs( geography = 'tract'
             ,state = 'MI'
             ,variables = c('S2704_C03_002','S2704_C03_006','S1701_C03_006')  
             ,year = 2020
             ,show_call = F) %>% 
    left_join(v_subject, by = c('variable' = 'name')) %>% 
    mutate_all(as.character)
  
  
  subject_acs<-bind_rows( subject_acs, iter_x)
  
}



subject_acs<-
  get_acs( geography = 'tract'
           ,state = 'MI'
           ,variables = c('S2704_C03_002','S2704_C03_006','S1701_C03_006')  
           ,year = 2020
           ,show_call = F) %>% 
  left_join(v_subject, by = c('variable' = 'name')) %>% 
  mutate_all(as.character)

subject_acs<-
  subject_acs %>% 
  mutate(
    label5 = coalesce(label5,""),
    var_name = str_to_lower(paste(label1,label3,label4,label5,sep = " ")),
    tract = GEOID,
    value = estimate) %>% 
  select(variable,tract,var_name,value) %>% 
  mutate_all(as.character) %>% 
  # Remove empty variables 
  mutate(var_check = ifelse(is.na(value),0,1)) %>% 
  group_by(var_name,variable) %>% 
  mutate(sum_check = sum(var_check,na.rm = T)) %>% 
  ungroup() %>% 
  filter(sum_check >0)  %>% 
  select(-var_check,-sum_check) %>% 
  distinct()


acs_data<-bind_rows(profile_acs,subject_acs)

# Getting land area 

tig = tibble()

for (st in unique(fips_codes$state[!fips_codes$state %in% c('AS','GU','MP','PR','UM','VI')])) {
  

tig_iter<-
  tigris::tracts(st) %>% 
  st_set_geometry(NULL) %>% 
  mutate(tract = GEOID) %>% 
  select(tract,area = ALAND)

tig = bind_rows(tig,tig_iter)

}

pop_density<-
  acs_data %>% 
  filter(variable == 'DP05_0001') %>% 
  select(-variable) %>% 
  mutate(value = case_when(is.na(value) ~ NA_real_, 
                           T ~ as.numeric(value))) %>% 
  na.omit() %>% 
  pivot_wider(id_cols = tract,names_from = var_name,values_from = value) %>% 
  rename_all(standard_name_format) %>% 
  left_join(tig, by = c("tract")) %>% 
  mutate(value = round((estimate_total_population/area)*1000,4),
         variable = 'Derived',
         var_name = 'Est. Population/Land Area') %>% 
  select(variable,tract,var_name,value) %>% 
  mutate_all(as.character)

acs_data = bind_rows(acs_data,pop_density)

rm(profile_acs,v_profile,tig,profile_acs_variables,analysis_df,
   industry_type,profile_acs_variables,standard_name_format,v
   ,v_frac,v_profile,v_subject,test,tig,pop_density,subject_acs)


# Attach variable short names (Update with any new variables)

short_names<-
  read_csv('data/census_dic.csv')


df<-
  acs_data %>% 
  left_join(short_names,by = 'variable') %>% 
  mutate(var_name = str_to_title(var_name),
         year = '2020',
         source = 'census') %>% 
  select(source,year,tract,var_short_name,value,var_name,variable)




rm(profile_acs,v_profile,tig,profile_acs_variables,analysis_df,
   industry_type,profile_acs_variables,standard_name_format,v
   ,v_frac,v_profile,v_subject,test,tig,pop_density,subject_acs)













