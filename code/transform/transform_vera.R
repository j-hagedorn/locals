library(tidyverse)



vera_df<-vera%>%
      filter(year > 1983)%>%
      select( year,county = fips,name = county_name,
              total_prison_pop,total_jail_pop,total_jail_pretrial,total_jail_from_prison,
              black_prison_pop,white_prison_pop,latinx_prison_pop,aapi_prison_pop, male_prison_pop,female_prison_pop,
              black_jail_pop, white_jail_pop,latinx_jail_pop,aapi_jail_pop,male_jail_pop,female_jail_pop,
              native_prison_pop,native_jail_pop,other_race_prison_pop,other_race_jail_pop
      )%>%
      mutate( dataset = 'vera',
              state = substr(county,1,2),
              stat_type = 'n'
      )%>%
      
      pivot_longer(cols = c(total_prison_pop,total_jail_pop,total_jail_pretrial,total_jail_from_prison,
                            
                            
                    black_prison_pop,white_prison_pop,latinx_prison_pop,aapi_prison_pop,native_prison_pop,
                    other_race_prison_pop,
                    male_prison_pop,female_prison_pop,
                    
                    black_jail_pop, white_jail_pop,latinx_jail_pop,aapi_jail_pop,native_jail_pop,
                    other_race_jail_pop,
                    male_jail_pop,female_jail_pop
                    
                    ),
                    names_to = "var_name",values_to = "value"
      )%>%
      mutate(race = case_when(str_detect(var_name,"black")~"black", 
                              str_detect(var_name,"white")~"white",
                              str_detect(var_name,"latinx")~"hispanic",
                              str_detect(var_name,"aapi")~"pacific",
                              str_detect(var_name,"native")~"natam",
                              str_detect(var_name,"other")~"other",
                              
                              TRUE ~ "pooled"),
            gender = case_when(str_detect(var_name,"female")~"female", 
                              str_detect(var_name,"male")~"male",
                              TRUE ~ "pooled"),
            age_range = "pooled",
            year = as.character(year),
            value = as.character(value),
            var_name  = case_when(str_detect(var_name,"black|white|latinx|aapi|native|other_race|male|female") ==TRUE ~
                           str_replace(var_name,"black|white|latinx|aapi|native|other_race|male|female","n_inmates"),
                           str_detect(var_name,"total")==TRUE ~ 
                              str_replace(var_name,"total","n_inmates"),
                              TRUE ~ NA_character_),
            var_name= str_remove(var_name,"_pop")
            
            
      )%>%
      select(dataset,state,county,year,race,gender,age_range,var_name,value,stat_type)


#test<-vera%>%
#      select(year,state,fips,male_jail_pop)%>%
#      filter(fips == '46125')


#===========================
# Append to counties
#===========================

library(DBI)

# database connection 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")


dbWriteTable(locals_db, name="counties", value= vera_df , append=T, row.names=F, overwrite=F)



