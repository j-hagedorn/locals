
#====================================#
# Creating aggregate variables ===== 
#====================================#


grab_query<-
  {paste("
        select *
        FROM [dbo].[counties]
        where var_name in (",vars_sql,") ",sep = "")
    
  }

county_var<-dbGetQuery(locals_db,grab_query)


# First creating a pooled variable set from medicaid, medicare, disability 
# status and uninsured population that came in the form of by-groups 


df_agg_by_groups<-
  county_var %>%
  # Only focusing on age and gender by-groups 
  filter(!(age_range == 'pooled' & gender == 'pooled' & race == 'pooled' )) %>%
  filter(race == 'pooled') %>%
  # Creating a grouping variable in order to summarize mutually exclusive 
  # by-groups for each category variable (medicaid,medicare,disability ect..)
  mutate(
    variable_group = case_when(str_detect(var_name,'medicare') ~ 'medicare_pop',
                               str_detect(var_name,'medicaid') ~ 'medicaid_pop',
                               str_detect(var_name,'health_insurance') ~ 'uninsured_pop',
                               str_detect(var_name,'disability') ~ 'disabled_pop',
                               T ~ "not classified")
    
  ) %>%
  # Grouping by the new variable and adding the sub-categories from 
  # within each group to derive a total. 
  group_by(dataset,state,county,year,variable_group) %>%
  summarise(value = as.character(sum(as.numeric(value),na.rm = T))) %>%
  ungroup() %>%
  mutate(
    var_name = variable_group,
    race = 'pooled',
    gender = 'pooled',
    age_range = 'pooled',
    stat_type = 'n'
  ) %>%
  select(-variable_group) %>%
  select(names(county_var))


# categorizing different proportions variables 
df<-
  county_var %>%
  # Removing by-group variables that were aggregated in previous step 
  # and attaching aggregated df.
  filter(str_detect(var_name,'medicare|medicaid|health_insurance|disability') ==F) %>%
  bind_rows(df_agg_by_groups) %>%
  mutate(
    denom_cat = case_when(str_detect(var_name,"pop|inmates") ~ "population_denom",
                          str_detect(var_name,"homes") ~ "homes_denom",
                          str_detect(var_name,"labor") ~ "labor_denom",
                          TRUE ~ 'other'
    ),
    value = as.numeric(value))


# Fraction of population related dataframe 

ttl_pop<-df%>%
  filter(var_name == 'ttl_est_pop')%>%
  mutate(ttl_pop = value)%>%
  select(county,year,ttl_pop)%>%
  distinct()

# Joining each counties total population 
# back to the original dataset to make the 
# division easier across the many numerators.

frac_pop = df%>%
  filter(denom_cat == 'population_denom')%>%
  filter(!var_name == 'ttl_est_pop')%>%
  left_join(ttl_pop,by = c('county','year'))%>%
  arrange(year) %>%
  mutate(
    value = round((value/ttl_pop)* 100,2),
    stat_type = 'frac', 
    var_name = str_replace_all(var_name,"^n_",""),
    var_name = paste0('frac_',var_name),
  )%>%
  filter(!is.na(value)) %>%
  select(dataset,state,county,year,race,gender,age_range,var_name,value,stat_type)


rm(ttl_pop)
# Fraction of homes related data frame 

# Joining each counties total homes 
# back to the original dataset to make the 
# division easier across the many numerators.

ttl_homes<-df%>%
  filter(var_name == 'ttl_est_homes')%>%
  mutate(ttl_homes = value)%>%
  select(county,year,ttl_homes)%>%
  distinct()


frac_homes = df%>%
  filter(denom_cat == 'homes_denom')%>%
  filter(!var_name == 'ttl_est_homes')%>%
  left_join(ttl_homes,by = c('county','year'))%>%
  arrange(year) %>%
  mutate(
    value = round((value/ttl_homes)* 100,2),
    stat_type = 'frac', 
    var_name = str_replace_all(var_name,"^n_",""),
    var_name = paste0('frac_',var_name),
  )%>%
  filter(!is.na(value)) %>%
  select(dataset,state,county,year,race,gender,age_range,var_name,value,stat_type)      

rm(ttl_homes)

# Fraction of labor related data frame (ACS5 labor force figures differ from BLS) 

ttl_labor<-df%>%
  filter(var_name == 'ttl_est_labor_force')%>%
  mutate(ttl_labor = value)%>%
  select(county,year,ttl_labor)%>%
  distinct()


frac_labor = df%>%
  filter(denom_cat == 'labor_denom')%>%
  filter(!var_name == 'ttl_est_labor_force')%>%
  left_join(ttl_labor,by = c('county','year'))%>%
  arrange(year) %>%
  mutate(
    value = round((value/ttl_labor)* 100,2),
    stat_type = 'frac', 
    var_name = str_replace_all(var_name,"^n_",""),
    var_name = paste0('frac_',var_name),
  )%>%
  filter(!is.na(value)) %>%
  select(dataset,state,county,year,race,gender,age_range,var_name,value,stat_type) 

rm(ttl_labor)

# Taking the aggregate variable as well

agg_num<-
  df %>%
  filter(var_name %in% c('medicare_pop','medicaid_pop','uninsured_pop','disabled_pop')) %>%
  distinct() %>%
  select(names(county_var))


# Combining the original dataset with the newly calculated proportions data set 

county_frac<-rbind(frac_pop,frac_labor,frac_homes,agg_num) %>%
  filter(!var_name == 'frac_ttl_est_not_in_labor_force')  %>%
  mutate(value =  round(as.numeric(value),2))

table(county_frac$var_name)
#=============================================# 
# Insert Fraction Variables Into Database ====
#=============================================# 


# Writing updated or new variables to data basae 
odbc::dbWriteTable(locals_db, 'counties', county_frac, append = T)

