**Under active development; not ready for use**

Purpose
=======

This repository contains scripts for reading, transforming and combining
datasets that are relevant for analysis of behavioral health and social
determinants of health (SDoH) at the local neighborhood level (using
‘census tract’ as a proxy for ‘neighborhood’) and, where necessary,
county level.

The list of datasets are tracked in the `.csv` file located in the data
folder, with more specific documentation found below as issues are
identified.

``` r
df %>%
  mutate(datalink = paste0("[",dataset,"](",url,")")) %>%
  select(topic,datalink,publisher) %>%
  arrange(topic) %>%
  knitr::kable()
```

| topic       | datalink                                                                                                                                                            | publisher                                 |
|:------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------|
| Behavioral  | [Behavioral Risk Factor Surveillance System](https://www.cdc.gov/brfss/annual_data/annual_2018.html)                                                                | CDC                                       |
| Commuting   | [Longitudinal Employer-Household Dynamics](https://lehd.ces.census.gov/)                                                                                            | US Census Bureau                          |
| COVID-19    | [COVID-19 Cases/Deaths by US County](https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv)                                                | New York Times                            |
| COVID-19    | [COVID-19 County Projections](https://github.com/SenPei-CU/COVID-19_US_Projection)                                                                                  | Columbia University                       |
| Density     | [Rural-Urban Commuting Area Codes](https://www.ers.usda.gov/webdocs/DataFiles/53241/ruca2010revised.xlsx?v=8632.5)                                                  | USDA                                      |
| Economic    | [Location Affordability Index](https://catalog.data.gov/dataset/location-affordability-index-all-census-counties)                                                   | Office of the Secretary of Transportation |
| Economic    | [Low-Income Housing Tax Credit](https://www.huduser.gov/portal/datasets/qct.html)                                                                                   | HUD                                       |
| Food        | [Food Environment Atlas](https://www.ers.usda.gov/data-products/food-environment-atlas/data-access-and-documentation-downloads.aspx#.VEXQQPnF-mE)                   | USDA                                      |
| Health      | [County Health Rankings](https://www.countyhealthrankings.org/sites/default/files/media/document/analytic_data2020.csv)                                             | U Wisc                                    |
| Health      | [WONDER Database](https://wonder.cdc.gov/wonder/help/WONDER-API.html)                                                                                               | CDC                                       |
| Health      | [500 Cities: Census Tract-level Data](https://www.opendatanetwork.com/dataset/chronicdata.cdc.gov/kucs-wizg)                                                        | CDC                                       |
| Healthcare  | [Geographic Variation Public Use File](https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Geographic-Variation/GV_PUF) | CMS                                       |
| Opportunity | [Neighborhood Atlas](https://www.neighborhoodatlas.medicine.wisc.edu/login)                                                                                         | U Wisc                                    |
| Opportunity | [Opportunity Insights Data](https://opportunityinsights.org/data/)                                                                                                  | Opportunity Insights                      |
| Provider    | [Adult Foster Care Homes](https://documents.apps.lara.state.mi.us/bchs/afc_sw.txt)                                                                                  | LARA                                      |
| Provider    | [Area Health Resources Files](https://data.hrsa.gov//DataDownload/AHRF/AHRF_2018-2019.ZIP)                                                                          | HRSA                                      |
| Provider    | [Health Professional Shortage Areas (HPSA) Mental Health](https://data.hrsa.gov//DataDownload/DD_Files/BCD_HPSA_FCT_DET_MH.csv)                                     | HRSA                                      |
| Provider    | [Health Professional Shortage Areas (HPSA) Primary Care](https://data.hrsa.gov//DataDownload/DD_Files/BCD_HPSA_FCT_DET_PC.csv)                                      | HRSA                                      |
| Provider    | [Medically Underserved Areas/Populations (MUA/P)](https://data.hrsa.gov//DataDownload/DD_Files/MUA_DET.csv)                                                         | HRSA                                      |
| Provider    | [NPPES](https://download.cms.gov/nppes/NPI_Files.html)                                                                                                              | CMS                                       |
| Social      | [Social Vulnerability Index](https://data.cdc.gov/Health-Statistics/Social-Vulnerability-Index-2018-United-States-coun/48va-t53r)                                   | CDC                                       |
| Social      | [Eviction Lab](https://evictionlab.org/get-the-data/)                                                                                                               | Princeton U                               |
| Various     | [American Community Survey](https://www.census.gov/data/developers/data-sets/acs-5year.html)                                                                        | US Census Bureau                          |
| Various     | [National Neighborhood Data Archive](https://www.openicpsr.org/openicpsr/search/nanda/studies;jsessionid=F2AA4AF121C2321A51D5D8294EAEA0C3)                          | NANDA                                     |
| Vital       | [National Vitality Statistics](ftp://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NVSS/USALEEP/CSV/)                                                             | CDC                                       |

Level of aggregation
====================

This list includes datasets which are available at one or more of the
following levels of aggregation:

-   Address (allows for geocoding and attribution of location to census
    tract)
-   Census Tract
-   County

These

Data Files
==========

COVID Cases
-----------

Census Variables
----------------

Variables from the census data (ACS 5-year estimate), including variants
of:

-   Poverty status
-   Disability status
-   Percent population over 65
-   Health insurance coverage
-   Incarceration

Social Vulnerability Index (CDC)
--------------------------------

This is derived from Census Data and includes, according to the
[documentation](https://svi.cdc.gov/Documents/Data/2018_SVI_Data/SVI2018Documentation.pdf),
four summary theme ranking variables:

-   Socioeconomic
-   Household Composition &Disability
-   Minority Status & Language
-   Housing Type & Transportation

Bureau of Labor and Statistics
------------------------------

From [here](https://www.bls.gov/lau/tables.htm):

-   Unemployment rate

County Health Ranking
---------------------

County health ranking data includes variables such as the following, as
shown in
[documentation](https://www.countyhealthrankings.org/sites/default/files/media/document/DataDictionary_2020_2.pdf):

-   Premature death
-   Poor physical health days
-   Poor mental health days
-   Food environment index
-   Adult smoking

Data available come from various sources, some of which may come from
sources available at census tract level
[here](https://www.countyhealthrankings.org/explore-health-rankings/measures-data-sources/2020-measures)

LARA AFC Homes
--------------

Hospitals
---------
