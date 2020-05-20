

# Primary care 
pc<-hpsa_primary_care%>%
    select(name = `HPSA Name`,
           id = `HPSA ID`, 
           designation_type = `Designation Type`,
           hpsa_status = `HPSA Status`,
           date = `HPSA Designation Last Update Date`,
           county_id = `Common State County FIPS Code`
          
          )%>%
          mutate(dataset = 'hpsa_primary_care'
          )%>%
          pivot_longer(cols = c(designation_type,hpsa_status), names_to = "var_name",
                                 values_to = "value"
          )%>%
          select(dataset,id,name,date,county_id,var_name,value)

# Mental health
mh<-hpsa_mental_health%>%
  select(name = `HPSA Name`,
         id = `HPSA ID`, 
         designation_type = `Designation Type`,
         hpsa_status = `HPSA Status`,
         date = `HPSA Designation Last Update Date`,
         county_id = `Common State County FIPS Code`
         
      )%>%
      mutate(dataset = 'hpsa_mental_health')%>%
      pivot_longer(cols = c(designation_type,hpsa_status), names_to = "var_name",
                             values_to = "value")%>%
      select(dataset,id,name,date,county_id,var_name,value)
  

# Combine 

full<-rbind(pc,mh)

#=======================
#Puch back to database
#=======================

# database connection 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")


copy_to(
  dest = locals_db,
  df = full,
  name = "wsu_public_county",
  overwrite = T,
  temporary = F
)







