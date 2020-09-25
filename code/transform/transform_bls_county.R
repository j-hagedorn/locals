library(tidyverse)


df<-employ_data%>%
    select(-1)%>%
    mutate(state = Code, 
           county = paste0(Code,Code_1),
           race = "pooled",
           gender = "pooled",
           age_range = "pooled",
           lbr_force = Force,
           nbr_emplyd = Employed, 
           nbr_unemplyd = Level,
           unemply_rate = Rate,
           stat_type = "n",
           dataset = 'bls')%>%
          select(stat_type, dataset,state,county,year = Year,race,gender,age_range,lbr_force,
                 nbr_emplyd,nbr_unemplyd,unemply_rate)%>%
          pivot_longer(cols = c(lbr_force,nbr_emplyd,nbr_unemplyd,unemply_rate),
                       names_to = "var_name",values_to = "value")%>%
         mutate_all(as.character)%>%
  select(
    dataset,state,county,year,
    race,gender,age_range,
    var_name,value,stat_type
  ) %>%
  distinct()


# Read each separate state file and append to database
# This assumes the existence of a system DSN named 'locals', which points to a db 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")
odbc::dbWriteTable(locals_db, "counties", df, append = T)










       