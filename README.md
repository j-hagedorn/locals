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

This list includes datasets which are available at one or more of the
following levels of aggregation:

-   Address (*allows for geocoding and attribution of location to census
    tract*)
-   Census Tract
-   County

These lower levels of aggregation can be rolled up to state level using
FIPS codes.

The list of datasets are tracked in the `.csv` file located in the data
folder, with more specific documentation found below as issues are
identified. Please push a commit marking the `complete` field in the
.csv file as `TRUE`. There are currently 6 datasets completed for
inclusion.

| topic       | datalink                                                                                                                                                            | publisher                                    | county                                                                                             | tract                                                                                | address                                                                                                                                    |
|:------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------------|:---------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------|
| Behavioral  | [Behavioral Risk Factor Surveillance System](https://www.cdc.gov/brfss/annual_data/annual_2018.html)                                                                | CDC                                          | [x](x)                                                                                             |                                                                                      |                                                                                                                                            |
| Commuting   | [Longitudinal Employer-Household Dynamics](https://lehd.ces.census.gov/data/lodes/LODES7/LODESTechDoc7.4.pdf)                                                       | US Census Bureau Center for Economic Studies | [x](x)                                                                                             | [x](x)                                                                               |                                                                                                                                            |
| COVID-19    | [COVID-19 Cases/Deaths by US County](https://github.com/nytimes/covid-19-data)                                                                                      | New York Times                               | [x](https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv)                |                                                                                      |                                                                                                                                            |
| COVID-19    | [COVID-19 County Projections](https://github.com/SenPei-CU/COVID-19_US_Projection)                                                                                  | Columbia University                          | [x](x)                                                                                             |                                                                                      |                                                                                                                                            |
| Density     | [Rural-Urban Commuting Area Codes](https://www.ers.usda.gov/webdocs/DataFiles/53241/ruca2010revised.xlsx?v=8632.5)                                                  | USDA                                         | [x](x)                                                                                             | [x](x)                                                                               |                                                                                                                                            |
| Economic    | [Location Affordability Index](https://catalog.data.gov/dataset/location-affordability-index-all-census-counties)                                                   | Office of the Secretary of Transportation    |                                                                                                    |                                                                                      |                                                                                                                                            |
| Economic    | [Low-Income Housing Tax Credit](https://www.huduser.gov/portal/datasets/qct.html)                                                                                   | HUD                                          |                                                                                                    | [x](x)                                                                               |                                                                                                                                            |
| Food        | [Food Environment Atlas](https://www.ers.usda.gov/data-products/food-environment-atlas/data-access-and-documentation-downloads.aspx#.VEXQQPnF-mE)                   | USDA                                         | [x](x)                                                                                             |                                                                                      |                                                                                                                                            |
| Health      | [County Health Rankings](https://www.countyhealthrankings.org/explore-health-rankings/measures-data-sources/2020-measures)                                          | U Wisc                                       | [x](https://www.countyhealthrankings.org/sites/default/files/media/document/analytic_data2020.csv) |                                                                                      |                                                                                                                                            |
| Health      | [WONDER Database](https://wonder.cdc.gov/wonder/help/WONDER-API.html)                                                                                               | CDC                                          |                                                                                                    |                                                                                      |                                                                                                                                            |
| Health      | [500 Cities: Census Tract-level Data](https://www.opendatanetwork.com/dataset/chronicdata.cdc.gov/kucs-wizg)                                                        | CDC                                          |                                                                                                    | [x](x)                                                                               |                                                                                                                                            |
| Healthcare  | [Geographic Variation Public Use File](https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Geographic-Variation/GV_PUF) | CMS                                          | [x](x)                                                                                             |                                                                                      |                                                                                                                                            |
| Opportunity | [Neighborhood Atlas](https://www.neighborhoodatlas.medicine.wisc.edu/login)                                                                                         | U Wisc                                       | [x](x)                                                                                             | [x](x)                                                                               |                                                                                                                                            |
| Opportunity | [All Outcomes by Race, Gender and Parental Income Percentile](https://opportunityinsights.org/wp-content/uploads/2019/07/Codebook-for-Table-4.pdf)                  | Opportunity Insights                         | [x](https://opportunityinsights.org/wp-content/uploads/2018/10/county_outcomes.zip)                | [x](https://opportunityinsights.org/wp-content/uploads/2018/10/tract_outcomes.zip)   |                                                                                                                                            |
| Opportunity | [Neighborhood Characteristics](https://opportunityinsights.org/wp-content/uploads/2019/07/Codebook-for-Table-9.pdf)                                                 | Opportunity Insights                         | [x](https://opportunityinsights.org/wp-content/uploads/2018/12/cty_covariates.csv)                 | [x](https://opportunityinsights.org/wp-content/uploads/2018/10/tract_covariates.csv) |                                                                                                                                            |
| Provider    | [Adult Foster Care Homes](https://www.michigan.gov/lara/0,4601,7-154-89334_63294_27717-56812--,00.html)                                                             | LARA                                         |                                                                                                    |                                                                                      | [x](https://documents.apps.lara.state.mi.us/bchs/afc_sw.txt)                                                                               |
| Provider    | [Area Health Resources Files](https://data.hrsa.gov//DataDownload/AHRF/AHRF_2018-2019.ZIP)                                                                          | HRSA                                         | [x](x)                                                                                             |                                                                                      |                                                                                                                                            |
| Provider    | [Health Professional Shortage Areas (HPSA) Mental Health](https://data.hrsa.gov//DataDownload/DD_Files/BCD_HPSA_FCT_DET_MH.csv)                                     | HRSA                                         | [x](x)                                                                                             | [x](?)                                                                               | [x](x)                                                                                                                                     |
| Provider    | [Health Professional Shortage Areas (HPSA) Primary Care](https://data.hrsa.gov//DataDownload/DD_Files/BCD_HPSA_FCT_DET_PC.csv)                                      | HRSA                                         | [x](x)                                                                                             | [x](?)                                                                               | [x](x)                                                                                                                                     |
| Provider    | [Medically Underserved Areas/Populations (MUA/P)](https://data.hrsa.gov//DataDownload/DD_Files/MUA_DET.csv)                                                         | HRSA                                         | [x](x)                                                                                             | [x](?)                                                                               | [x](x)                                                                                                                                     |
| Provider    | [NPPES](https://download.cms.gov/nppes/NPI_Files.html)                                                                                                              | CMS                                          |                                                                                                    |                                                                                      | [x](x)                                                                                                                                     |
| Provider    | [Inpatient Psychiatric Facility Quality Measure Data by Facility](https://catalog.data.gov/dataset/inpatient-psychiatric-facility-quality-measure-data-by-facility) | CMS                                          |                                                                                                    |                                                                                      | [x](https://data.medicare.gov/api/views/q9vs-r7wp/rows.csv?accessType=DOWNLOAD)                                                            |
| Provider    | [Hospitals](https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals)                                                                                       | HIFLD                                        |                                                                                                    |                                                                                      | [x](https://opendata.arcgis.com/datasets/6ac5e325468c4cb9b905f1728d6fbf0f_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D) |
| Provider    | [Prison Boundaries](https://hifld-geoplatform.opendata.arcgis.com/datasets/prison-boundaries)                                                                       | HIFLD                                        |                                                                                                    |                                                                                      | [x](https://opendata.arcgis.com/datasets/2d6109d4127d458eaf0958e4c5296b67_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D) |
| Provider    | [Local Law Enforcement Locations](https://hifld-geoplatform.opendata.arcgis.com/datasets/local-law-enforcement-locations)                                           | HIFLD                                        |                                                                                                    |                                                                                      | [x](https://opendata.arcgis.com/datasets/0d79b978d71b4654bddb6ca0f4b7f830_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D) |
| Provider    | [Nursing Homes](https://hifld-geoplatform.opendata.arcgis.com/datasets/nursing-homes)                                                                               | HIFLD                                        |                                                                                                    |                                                                                      | [x](https://opendata.arcgis.com/datasets/78c58035fb3942ba82af991bb4476f13_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D) |
| Social      | [Social Vulnerability Index](https://svi.cdc.gov/Documents/Data/2018_SVI_Data/SVI2018Documentation.pdf)                                                             | CDC                                          | [x](https://data.cdc.gov/api/views/48va-t53r/rows.csv?accessType=DOWNLOAD)                         | [x](https://data.cdc.gov/api/views/4d8n-kk8a/rows.csv?accessType=DOWNLOAD)           |                                                                                                                                            |
| Social      | [Eviction Lab](https://data-downloads.evictionlab.org/)                                                                                                             | Princeton U                                  | [x](x)                                                                                             | [x](x)                                                                               |                                                                                                                                            |
| Various     | [American Community Survey](https://www.census.gov/data/developers/data-sets/acs-5year.html)                                                                        | US Census Bureau                             | [x](https://github.com/walkerke/tidycensus)                                                        | [x](https://github.com/walkerke/tidycensus)                                          |                                                                                                                                            |
| Various     | [National Neighborhood Data Archive](https://www.openicpsr.org/openicpsr/search/nanda/studies;jsessionid=F2AA4AF121C2321A51D5D8294EAEA0C3)                          | NANDA                                        | [x](x)                                                                                             | [x](x)                                                                               |                                                                                                                                            |
| Vital       | [National Vitality Statistics](ftp://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NVSS/USALEEP/CSV/)                                                             | CDC                                          | [x](x)                                                                                             |                                                                                      |                                                                                                                                            |

Processing and Format
=====================

There are different output file formats for each level of aggregation in
the data.

Census Tract Dataset
--------------------

The following fields must be included in all files:

-   `dataset`: A shortened name of the dataset, to allow for subsetting
    when datasets are combined.
-   `state`: Two-digit state 2010 FIPS code
-   `county`: Three-digit county 2010 FIPS code
-   `tract`: Six-digit tract 2010 FIPS code
-   `year`: The year of the published dataset.
-   `race`: Should be marked as `pooled` where data is not broken out by
    race. Should be marked as `NA` when the variable is not related to a
    population metric, such as in a count of facilities.
-   `gender`: Should be marked as `pooled` where data is not broken out
    by gender. Should be marked as `NA` when the variable is not related
    to a population metric, such as in a count of facilities.
-   `age_range`: Should be marked as `pooled` where data is not broken
    out by age range. Should be marked as `NA` when the variable is not
    related to a population metric, such as in a count of facilities.
-   `var_name`: The name of the variable/metric being reported.
-   `value`: The numeric value of the measure identified in `var_name`
-   `stat_type`: The type of summary statistic being reported in
    `value`. For example: `n`, `mean`, `se`, `median`, etc.

County-level Dataset
--------------------

All fields from the census tract level data should be included in all
files, other than the `tract` variable.

Address Dataset
---------------

Address-level datasets should include the following fields:

-   `dataset`: A shortened name of the dataset, to allow for subsetting
    when datasets are combined.
-   `state`:
-   `county`:
-   `tract`: The census tract within which the address is located,
    obtained by using the `TBDfun::census_tract` function.
-   `address`:
-   `lat`, `lon`: Geocoded latitude and longitude coordinates of
    `address`
-   `year`: The year of the published dataset.
-   `...`: Other variables specific to the dataset, which may be of
    value to retain, though these will not be aggregated in the tract or
    county-level data.

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

From
[here](https://github.com/nytimes/covid-19-data/blob/master/README.md)

-   Date
-   Cases
-   Deaths

COVID Projections
-----------------

From
[here](https://github.com/SenPei-CU/COVID-19_US_Projection/blob/master/README.md)

-   Date
-   Report Median
-   Report 2.5
-   Report 25
-   Report 75
-   Report 97.5
-   Total Median
-   Total 2.5
-   Total 25
-   Total 75
-   Total 97.5

Opportunity Atlas
-----------------

Opportunity Insights is a non-partisan, not-for-profit organization
based at Harvard University. We incorporate data from their datasets
which inform *The Opportunity Atlas: Mapping the Childhood Roots of
Social Mobility*, specifically the following:

-   [All Outcomes by Census Tract, Race, Gender and Parental Income
    Percentile](https://opportunityinsights.org/wp-content/uploads/2019/07/Codebook-for-Table-4.pdf)
-   [Neighborhood Characteristics by Census
    Tract](https://opportunityinsights.org/wp-content/uploads/2019/07/Codebook-for-Table-9.pdf)

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
