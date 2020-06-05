library(tidyverse)

# data was manually downloaded from the SAMHHSA facility locator page
# found here https://findtreatment.samhsa.gov/locator. Website only allows 
# for exports of multiple csvs of 30,000 rows each

df1 = read_csv("data/Behavioral_Health_Treament_Facility_listing_file1.csv")

df2 = read_csv("data/Behavioral_Health_Treament_Facility_listing_file2.csv")

