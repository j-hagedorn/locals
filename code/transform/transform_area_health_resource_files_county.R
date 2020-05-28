#================================
# pull columns and provide 
# some meaning to variables
# from the documentation 
#===============================


ahrf_df<-ahrf_df%>%
  select( state = FIPS.State.Code,
          county = FIPS.County.Code,
          
          economy_type = Economic.Dependnt.Typology.Code.2015,
          #The County typology classifies all U.S. counties according to six mutually
          #exclusive (non-overlapping) categories of economic dependence and six overlapping 
          #categories of policy-relevant themes.  
          #0 = Nonspecialized
          #1 = Farming-dependent county
          #2 = Mining-dependent county
          #3 = Manufacturing-dependent county
          #4 = Federal/State government-dependent county
          #5 = Recreation
          
          rural_urban_cont =  Rural.Urban.Continuum.Code.2013,
          #The 2013 Rural/Urban Continuum Codes are defined as follows:
          #CODE METROPOLITAN COUNTIES (1-3)
          #01		Counties in metro areas of 1 million population or more
          #02		Counties in metro areas of 250,000 – 1,000,000 population
          #03		Counties in metro areas of fewer than 250,000 population
          
          #NONMETROPOLITAN COUNTIES (4-9)
          #04		Urban population of 20,000 or more, adjacent to a metro area
          #05		Urban population of 20,000 or more, not adjacent to a metro area
          #06		Urban population of 2,500-19,999, adjacent to a metro area
          #07		Urban population of 2,500-19,999, not adjacent to a metro area
          #08		Completely rural or less than 2,500 urban population, adjacent to a metro area
          #09		Completely rural or less than 2,500 urban population, not adjacent to a metro area
          
          
          metro_nonMetro = Urban.Influence.Code.2013,
          # Metro vs Non-Metro
          
          #METROPOLITAN
          #1		In a large metro area of 1 million residents or more 
          #2		In a small metro area of less than 1 million residents 
          
          #NONMETROPOLITAN
          #3		Micropolitan area adjacent to a large metro area 
          #4		Noncore adjacent to a large metro area 
          #5		Micropolitan area adjacent to a small metro area 
          #6		Noncore adjacent to a small metro area with a town of at least 2,500
          #7	  Noncore adjacent to a small metro area and does not contain a town of at least 2,500 residents
          #8		Micropolitan area not adjacent to a metro area 
          #9		Noncore adjacent to a micro area and contains a town of at least 2,500 residents
          #10	  Noncore adjacent to micro area and does not contain a town of at least 2,500 residents
          #11	  Noncore not adjacent to a metro or micro area and contains a town of at least 2,500 or more residents
          #12	  Noncore not adjacent to a metro or micro area and does not contain a town of at least 2,500 residents
          
          prvtble_hsp_stys_medcre_rte_enrles = Preventable.Hospital.Stays.Rate.Medicare.FFS.Enrollees.2016,
          #Medicare.FFS.Beneficiaries.Fee.for.Service.2016,
          #Medicare.Enrollment..Aged.Tot.2016
          
          
  )%>%
  mutate_all(as.character)%>%
  pivot_longer(cols = c(economy_type,rural_urban_cont,
                        metro_nonMetro,prvtble_hsp_stys_medcre_rte_enrles),
               names_to = 'var_name',values_to = 'value')%>%
  mutate(year = case_when(var_name == 'economy_type' ~ '2015',
                           var_name == 'rural_urban_cont' ~ '2013',
                          var_name == 'metro_nonMetro' ~ '2013',
                          var_name == 'prvtble_hsp_stys_medcre_rte_enrles' ~ '2016',
                          TRUE ~ NA_character_),
         race = 'pooled',
         gender = 'pooled',
         age_range = 'pooled',
         stat_type = case_when(var_name == 'prvtble_hsp_stys_medcre_rte_enrles' ~ 'n',
                               TRUE ~ 'cat'),
         dataset = 'ahrf')%>%
  select(dataset,state,county,year,race,gender,age_range,var_name,value,stat_type)

#===============================
# Append to counties dataset
#===============================

library(DBI)

# database connection 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")


dbWriteTable(locals_db, name="counties", value= ahrf_df , append=T, row.names=F, overwrite=F)






