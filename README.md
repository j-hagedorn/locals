**Under active development; not ready for use**

Purpose
=======

This repository contains scripts for reading, transforming and combining
datasets that are relevant for analysis of behavioral health and social
determinants of health (SDoH) at the local neighborhood level (using
‘census tract’ as a proxy for ‘neighborhood’) and, where necessary,
county level.

Datasets
========

The list of datasets are tracked in the `.csv` file located in the data
folder, with more specific documentation found below as issues are
identified. Please push a commit marking the `complete` field in the
.csv file as `TRUE`. There are currently 0 datasets completed for
inclusion.

| topic       | datalink                                                                                                                                                            | publisher                                 | county                                                                                             | tract                                                 | address                                                      |
|:------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------|:---------------------------------------------------------------------------------------------------|:------------------------------------------------------|:-------------------------------------------------------------|
| Behavioral  | [Behavioral Risk Factor Surveillance System](https://www.cdc.gov/brfss/annual_data/annual_2018.html)                                                                | CDC                                       | [x](x)                                                                                             | NA                                                    | NA                                                           |
| Commuting   | [Longitudinal Employer-Household Dynamics](https://lehd.ces.census.gov/)                                                                                            | US Census Bureau                          | NA                                                                                                 | NA                                                    | NA                                                           |
| COVID-19    | [COVID-19 Cases/Deaths by US County](https://github.com/nytimes/covid-19-data)                                                                                      | New York Times                            | [x](x)                                                                                             | NA                                                    | NA                                                           |
| COVID-19    | [COVID-19 County Projections](https://github.com/SenPei-CU/COVID-19_US_Projection)                                                                                  | Columbia University                       | [x](x)                                                                                             | NA                                                    | NA                                                           |
| Density     | [Rural-Urban Commuting Area Codes](https://www.ers.usda.gov/webdocs/DataFiles/53241/ruca2010revised.xlsx?v=8632.5)                                                  | USDA                                      | [x](x)                                                                                             | [x](x)                                                | NA                                                           |
| Economic    | [Location Affordability Index](https://catalog.data.gov/dataset/location-affordability-index-all-census-counties)                                                   | Office of the Secretary of Transportation | NA                                                                                                 | NA                                                    | NA                                                           |
| Economic    | [Low-Income Housing Tax Credit](https://www.huduser.gov/portal/datasets/qct.html)                                                                                   | HUD                                       | NA                                                                                                 | [x](x)                                                | NA                                                           |
| Food        | [Food Environment Atlas](https://www.ers.usda.gov/data-products/food-environment-atlas/data-access-and-documentation-downloads.aspx#.VEXQQPnF-mE)                   | USDA                                      | [x](x)                                                                                             | NA                                                    | NA                                                           |
| Health      | [County Health Rankings](https://www.countyhealthrankings.org/explore-health-rankings/measures-data-sources/2020-measures)                                          | U Wisc                                    | [x](https://www.countyhealthrankings.org/sites/default/files/media/document/analytic_data2020.csv) | NA                                                    | NA                                                           |
| Health      | [WONDER Database](https://wonder.cdc.gov/wonder/help/WONDER-API.html)                                                                                               | CDC                                       | NA                                                                                                 | NA                                                    | NA                                                           |
| Health      | [500 Cities: Census Tract-level Data](https://www.opendatanetwork.com/dataset/chronicdata.cdc.gov/kucs-wizg)                                                        | CDC                                       | NA                                                                                                 | [x](x)                                                | NA                                                           |
| Healthcare  | [Geographic Variation Public Use File](https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Geographic-Variation/GV_PUF) | CMS                                       | [x](x)                                                                                             | NA                                                    | NA                                                           |
| Opportunity | [Neighborhood Atlas](https://www.neighborhoodatlas.medicine.wisc.edu/login)                                                                                         | U Wisc                                    | NA                                                                                                 | [x](x)                                                | NA                                                           |
| Opportunity | [Opportunity Insights Data](https://opportunityinsights.org/data/)                                                                                                  | Opportunity Insights                      | [x](x)                                                                                             | [x](x)                                                | NA                                                           |
| Provider    | [Adult Foster Care Homes](https://www.michigan.gov/lara/0,4601,7-154-89334_63294_27717-56812--,00.html)                                                             | LARA                                      | NA                                                                                                 | NA                                                    | [x](https://documents.apps.lara.state.mi.us/bchs/afc_sw.txt) |
| Provider    | [Area Health Resources Files](https://data.hrsa.gov//DataDownload/AHRF/AHRF_2018-2019.ZIP)                                                                          | HRSA                                      | [x](x)                                                                                             | NA                                                    | NA                                                           |
| Provider    | [Health Professional Shortage Areas (HPSA) Mental Health](https://data.hrsa.gov//DataDownload/DD_Files/BCD_HPSA_FCT_DET_MH.csv)                                     | HRSA                                      | [x](x)                                                                                             | [x](?)                                                | [x](x)                                                       |
| Provider    | [Health Professional Shortage Areas (HPSA) Primary Care](https://data.hrsa.gov//DataDownload/DD_Files/BCD_HPSA_FCT_DET_PC.csv)                                      | HRSA                                      | [x](x)                                                                                             | [x](?)                                                | [x](x)                                                       |
| Provider    | [Medically Underserved Areas/Populations (MUA/P)](https://data.hrsa.gov//DataDownload/DD_Files/MUA_DET.csv)                                                         | HRSA                                      | [x](x)                                                                                             | [x](?)                                                | [x](x)                                                       |
| Provider    | [NPPES](https://download.cms.gov/nppes/NPI_Files.html)                                                                                                              | CMS                                       | NA                                                                                                 | NA                                                    | [x](x)                                                       |
| Social      | [Social Vulnerability Index](https://svi.cdc.gov/Documents/Data/2018_SVI_Data/SVI2018Documentation.pdf)                                                             | CDC                                       | [x](https://svi.cdc.gov/data-and-tools-download.html)                                              | [x](https://svi.cdc.gov/data-and-tools-download.html) | NA                                                           |
| Social      | [Eviction Lab](https://evictionlab.org/get-the-data/)                                                                                                               | Princeton U                               | [x](x)                                                                                             | [x](x)                                                | NA                                                           |
| Various     | [American Community Survey](https://www.census.gov/data/developers/data-sets/acs-5year.html)                                                                        | US Census Bureau                          | [x](https://github.com/walkerke/tidycensus)                                                        | [x](https://github.com/walkerke/tidycensus)           | NA                                                           |
| Various     | [National Neighborhood Data Archive](https://www.openicpsr.org/openicpsr/search/nanda/studies;jsessionid=F2AA4AF121C2321A51D5D8294EAEA0C3)                          | NANDA                                     | [x](x)                                                                                             | [x](x)                                                | NA                                                           |
| Vital       | [National Vitality Statistics](ftp://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NVSS/USALEEP/CSV/)                                                             | CDC                                       | [x](x)                                                                                             | NA                                                    | NA                                                           |

Processing and Format
=====================

There are different output file formats for each level of aggregation in
the data.

County-level Dataset
--------------------

Census Tract Dataset
--------------------

Level of aggregation
====================

This list includes datasets which are available at one or more of the
following levels of aggregation:

-   Address (*allows for geocoding and attribution of location to census
    tract*)
-   Census Tract
-   County

These lower levels of aggregation can be rolled up to state level using
FIPS codes.

Dataset Details
===============

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

COVID Cases
-----------

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
