
library(tidycensus)

v18 <- load_variables(2018, "acs5", cache = TRUE)

View(v18)
B27001_001

# males only 19-64, need to add more. 
medicare_medicaid <- 
  get_acs(geography = "county", 
          variables = c("C27007_007","B992707_001","B01003_001"),
         # geometry = TRUE,
  state = 'MI',
          year = 2018
 )


medicaid means tested public coverage male = C27007_006
medicaid means tested public coverage female = 	C27007_016

medicare coverage = B992706_001 total population 
medicaid coverage = B992707_001 total population 

# 

uninsured_county <- 
  get_acs(geography = "county", 
          variables = c("B18135_007","B18135_012",
                        "B18135_018","B18135_023",
                        "B18135_029","B18135_034",
                        "B27001_005"),
          state = 'MI',
          year = 2018
  )


test<-us_county%>%
      group_by(GEOID)%>%
      summarise(uninsured = sum(estimate,na.rm = TRUE))




