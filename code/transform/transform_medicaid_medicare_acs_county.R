




full<-acs5_county%>%
  mutate( dataset = "acs_5",
          state = substr(GEOID,1,2),
          county = GEOID,
          year = '2018',
          estimate = as.character(estimate),
          stat_type = "n"
  )%>%
  select(dataset,state,county,year,race,gender,
         age_range,var_name,value = estimate,
         stat_type)


#===========================
# Append to master counties
#===========================

locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

dbWriteTable(locals_db, name="counties", value=full , append=T, row.names=F, overwrite=F)
