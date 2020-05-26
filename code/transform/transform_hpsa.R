
# Primary care 
pc<-hpsa_primary_care%>%
    select(name = `HPSA Name`,
           id = `HPSA ID`, 
           designation_type = `Designation Type`,
           hpsa_status = `HPSA Status`,
           year = `HPSA Designation Last Update Date`,
           county = `Common State County FIPS Code`,
           state = `Common State FIPS Code`
          
          )%>%
          mutate(dataset = 'hpsa_primary_care',
                 county = str_sub(county,3,5),
                 race = "pooled",
                 gender = "pooled",
                 age_range = "pooled",
                 stat_type = 'cat'
                 
                 
          )%>%
          pivot_longer(cols = c(designation_type,hpsa_status), names_to = "var_name",
                                 values_to = "value"
          )%>%
          select(dataset,state,county,year,race,gender,age_range,var_name,value,stat_type)

# Mental health
mh<-hpsa_mental_health%>%
  select(name = `HPSA Name`,
         id = `HPSA ID`, 
         designation_type = `Designation Type`,
         hpsa_status = `HPSA Status`,
         year = `HPSA Designation Last Update Date`,
         county = `Common State County FIPS Code`,
         state = `Common State FIPS Code`
         
  )%>%
  mutate(dataset = 'hpsa_mental_health',
         county = str_sub(county,3,5),
         race = "pooled",
         gender = "pooled",
         age_range = "pooled",
         stat_type = 'cat'
         
         
  )%>%
  pivot_longer(cols = c(designation_type,hpsa_status), names_to = "var_name",
               values_to = "value"
  )%>%
  select(dataset,state,county,year,race,gender,age_range,var_name,value,stat_type)
  

# Combine 
full<-rbind(pc,mh)%>%
      mutate(state = as.character(state))

#===========================
# Append to master counties
#===========================
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

dbWriteTable(locals_db, name="counties", value=full , append=T, row.names=F, overwrite=F)







