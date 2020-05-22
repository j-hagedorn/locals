

full_tract<-acs5_tract%>%
  mutate( dataset = "acs_5",
            state = str_sub(GEOID,1,2),
            county = str_sub(GEOID,3,5),
            tract = str_sub(GEOID,6,11),
          year = '2018',
          estimate = as.character(estimate),
          stat_type = "n"
  )%>%
  select(dataset,state,county,tract,year,race,gender,
         age_range,var_name,value = estimate,
         stat_type)


#===========================
# Append to master counties
#===========================

#locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

dbWriteTable(locals_db, name="tracts", value=full_tract , append=T, row.names=F, overwrite=F)
