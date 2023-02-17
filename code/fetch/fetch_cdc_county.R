library(tidyverse)
library(tigris)
library(data.table)
library(bcputility)

county_codes =
  get(data("fips_codes")) %>% 
  mutate(fips = paste0(state_code,county_code), 
         county_name = str_squish(str_replace_all(county,"County",""))) %>% 
  select(fips,StateAbbr=state,county_name)



df<-
  bind_rows(
    # Suicide Data 
    # 2016-2020 sum
    # ICD X60-X84 (Intentional self-harm)
    read_delim('data/suicide.txt') %>% 
      filter(!is.na(County)) %>% 
      mutate(
        deaths = case_when(!Deaths == 'Suppressed' ~ as.numeric(Deaths),
                           T ~ NA_real_),
        value = round(deaths / as.numeric(Population) * 100000,1),
        var_name = "Suicide Crude Prevelance per 100K of the Population",
        var_short_name = 'Suicide Rate 100K',
        state = substr(`County Code`,1,2),
        county = `County Code`, 
        year = '2020', 
        var = 'ICD X60-X84',
        stat_type = 'rate', 
        dataset = 'CDC Wonder:5-Year'
      ) %>% 
      select(dataset,state,county,year,var,var_name,var_short_name,value,stat_type) %>% 
      mutate_all(as.character),
    
    
    # Prescription Opioid Overdose 
    # 2016-2020 
    # UCD Drug poisonings (overdose) Unintentional (X40-X44)
    # UCD Drug poisonings (overdose) Suicide (X60-X64)
    # UCD Drug poisonings (overdose) Homicide (X85)
    # UCD Drug poisonings (overdose) Undetermined (Y10-Y14)
    # ICD T40.2 T40.3 - Prescription Opioid Specific
    read_delim('data/presc_opioid.txt') %>% 
      filter(!is.na(County)) %>% 
      mutate(
        deaths = case_when(!Deaths == 'Suppressed' ~ as.numeric(Deaths),
                           T ~ NA_real_),
        value = round(deaths / as.numeric(Population) * 100000,1),
        var_name = "Prescription Opioid Overdose Crude Prevalence per 100K of the Population",
        var_short_name = 'Presc. Opioid Overdose Rate 100K',
        state = substr(`County Code`,1,2),
        county = `County Code`, 
        var = 'ICD T40.2 T40.3 - Prescription Opioid Specific',
        stat_type = 'rate', 
        dataset = 'CDC Wonder'
      ) %>% 
      select(dataset,state,county,year=Year,var,var_name,var_short_name,value,stat_type) %>% 
      mutate_all(as.character),
    
    # Drug Overdose 
    # 2016-2020 
    # UCD Drug poisonings (overdose) Unintentional (X40-X44)
    # UCD Drug poisonings (overdose) Suicide (X60-X64)
    # UCD Drug poisonings (overdose) Homicide (X85)
    # UCD Drug poisonings (overdose) Undetermined (Y10-Y14)
      read_delim('data/drug_overdose.txt') %>% 
      filter(!is.na(County)) %>% 
      mutate(
        deaths = case_when(!Deaths == 'Suppressed' ~ as.numeric(Deaths),
                           T ~ NA_real_),
        value = round(deaths / as.numeric(Population) * 100000,1),
        var_name = "Drug Overdose Crude Prevalence per 100K of the Population",
        var_short_name = 'Drug Overdose Rate 100K',
        state = substr(`County Code`,1,2),
        county = `County Code`, 
        var = 'UCD Drug poisonings-overdose(Y10-Y14)(X85)(X60-X64)(X40-X44)',
        stat_type = 'rate', 
        dataset = 'CDC Wonder'
      ) %>% 
      select(dataset,state,county,year=Year,var,var_name,var_short_name,value,stat_type) %>% 
      mutate_all(as.character)
  )



# You will need to specify the exact path to the BCP utility tool 
# It will likely be very similar to this path, but you should double-check. 
options(bcputility.bcp.path = "C:/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/bcp.exe")

start<-Sys.time()

bcpImport(
  df, # The data frame you wish to upload
  # SQL Connections
  connectargs = makeConnectArgs(
    server = Sys.getenv('tbd_server_address'),
    database = 'locals',
    trustedconnection = TRUE
  ), # If TRUE, this will Windows authenticate. Be sure you are connected to the VPN. 
  table  = 'counties', # Name of the table to store the data frame you wish to upload
  overwrite = F, # Will overwrite the table or create a table if one dosen't exist
  bcpOptions = c('-b 50000') # This refers to the batch size of the number of rows sent at a time.Feel free to mess around with figure. This was a recommendation. 
  # *If an error occurs, ensure all columns are NVARCHAR(MAX) in SQL
)





