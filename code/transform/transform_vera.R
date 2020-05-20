

vera_df<-vera%>%
  filter(year > 1983)%>%
  select(date = year,county_id = fips,name = county_name,
         total_pop,total_prison_pop,total_jail_pop,total_jail_pretrial,total_jail_from_prison,
         black_prison_pop,white_prison_pop,latinx_prison_pop,aapi_prison_pop, male_prison_pop,female_prison_pop,
         black_jail_pop, white_jail_pop,latinx_jail_pop,aapi_jail_pop,male_jail_pop,female_jail_pop
  )%>%
  mutate(dataset = 'vera',
         id = NA_character_)%>%
  pivot_longer(cols = c(total_pop,total_prison_pop,total_jail_pop,total_jail_pretrial,total_jail_from_prison,
                        black_prison_pop,white_prison_pop,latinx_prison_pop,aapi_prison_pop, male_prison_pop,female_prison_pop,
                        black_jail_pop, white_jail_pop,latinx_jail_pop,aapi_jail_pop,male_jail_pop,female_jail_pop),
               names_to = "var_name",values_to = "value")%>%
  select(dataset,id,name,date,county_id,var_name,value)


#===========================
# Append to WSU Crime Data
#===========================

library(DBI)

# database connection 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

dbWriteTable(conn =  locals_db,
              "wsu_public_county",
               vera_df,
               append = TRUE

              )


