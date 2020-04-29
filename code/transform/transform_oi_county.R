library(tidyverse); library(foreach); library(doParallel) 

# Fetch from web for initial load, using:
# source("code/fetch/fetch_oi_tract.R")
# oi_tract <- fetch_oi_tract()

oi_county <- feather::read_feather("data/oi_county.feather")
oi_covar <- feather::read_feather("data/oi_covar_county.feather")

cl <- parallel::makeCluster(2, type = 'SOCK', nnodes = detectCores()/2)
registerDoParallel(cl)
memory.limit(30000)
# Make a new dir 
dir.create("data/oi_files")

# Transform and save each state file separately to avoid crash

foreach (i = unique(oi_county$state)) %dopar% {
  
  library(tidyverse)
  memory.limit(30000)
  
  df <-
    oi_county %>% 
    filter(state == i) %>%
    mutate_all(~as.character(.)) %>%
    select(-cz,-czname) %>%
    pivot_longer(cols = -one_of("state","county")) %>% 
    # Remove NA values for memory
    filter(!is.na(value)) %>%
    mutate(
      value = as.numeric(value),
      var_name = case_when(
        str_detect(name,"^has_dad") ~ "has_dad",
        str_detect(name,"^has_mom") ~ "has_mom",
        str_detect(name,"^jail") ~ "jail",
        str_detect(name,"^kfr_stycz") ~ "kfr_stycz",
        str_detect(name,"^kfr_top01") ~ "kfr_top01",
        str_detect(name,"^kfr_top20") ~ "kfr_top20",
        str_detect(name,"^kfr_24") ~ "kfr_24",
        str_detect(name,"^kfr_26") ~ "kfr_26",
        str_detect(name,"^kfr_29") ~ "kfr_29",
        str_detect(name,"^kfr")    ~ "kfr",
        str_detect(name,"^kir_stycz") ~ "kir_stycz",
        str_detect(name,"^kir_top01") ~ "kir_top01",
        str_detect(name,"^kir_top20") ~ "kir_top20",
        str_detect(name,"^kir_24") ~ "kir_24",
        str_detect(name,"^kir_26") ~ "kir_26",
        str_detect(name,"^kir_29") ~ "kir_29",
        str_detect(name,"^kir") ~ "kir",
        str_detect(name,"^frac_below_median") ~ "frac_below_median",
        str_detect(name,"^frac_years_xw") ~ "frac_years_xw",
        str_detect(name,"^par_rank") ~ "par_rank",
        str_detect(name,"^kid") ~ "kid",
        str_detect(name,"^lpov_nbh") ~ "lpov_nbh",
        str_detect(name,"^married") ~ "married",
        str_detect(name,"^marr_24") ~ "marr_24",
        str_detect(name,"^marr_26") ~ "marr_26",
        str_detect(name,"^marr_29") ~ "marr_29",
        str_detect(name,"^marr_32") ~ "marr_32",
        str_detect(name,"^spouse_rk") ~ "spouse_rk",
        str_detect(name,"^stayhome") ~ "stayhome",
        str_detect(name,"^staycz") ~ "staycz",
        str_detect(name,"^staytract") ~ "staytract",
        str_detect(name,"^teenbrth") ~ "teenbrth",
        str_detect(name,"^two_par") ~ "two_par",
        str_detect(name,"^working") ~ "working",
        str_detect(name,"^work_24") ~ "work_24",
        str_detect(name,"^work_26") ~ "work_26",
        str_detect(name,"^work_29") ~ "work_29",
        str_detect(name,"^work_32") ~ "work_32",
        str_detect(name,"^coll") ~ "coll",
        str_detect(name,"^comcoll") ~ "comcoll",
        str_detect(name,"^grad") ~ "grad",
        str_detect(name,"^hours_wk") ~ "hours_wk",
        str_detect(name,"^hs") ~ "hs",
        str_detect(name,"^pos_hours") ~ "pos_hours",
        str_detect(name,"^proginc") ~ "proginc",
        str_detect(name,"^somecoll") ~ "somecoll",
        str_detect(name,"^wgflx_rk") ~ "wgflx_rk",
        TRUE ~ NA_character_
      ),
      race = case_when(
        str_detect(name,"hisp_") ~ "hispanic",
        str_detect(name,"black_") ~ "black",
        str_detect(name,"white_") ~ "white",
        str_detect(name,"asian_") ~ "asian",
        str_detect(name,"natam_") ~ "natam",
        str_detect(name,"other_") ~ "other",
        TRUE ~ "pooled"
      ),
      gender = case_when(
        str_detect(name,"_male") ~ "male",
        str_detect(name,"_female") ~ "female",
        TRUE ~ "pooled"
      ),
      age_range = "pooled",
      year = NA_character_,
      stat_type = case_when(
        str_detect(name,"_mean$") ~ "mean",
        str_detect(name,"_mean_se$") ~ "mean_se",
        str_detect(name,"_blw_p50_n$") ~ "blw_p50_n",
        str_detect(name,"_n$") ~ "n",
        str_detect(name,"^frac_below_median_") ~ "frac",
        str_detect(name,"^frac_years_xw_") ~ "frac",
        str_detect(name,"_p1$") ~ "p1",
        str_detect(name,"_p10$") ~ "p10",
        str_detect(name,"_p25$") ~ "p25",
        str_detect(name,"_p50$") ~ "p50",
        str_detect(name,"_p75$") ~ "p75",
        str_detect(name,"_p100$") ~ "p100",
        str_detect(name,"_p1_se$") ~ "p1_se",
        str_detect(name,"_p25_se$") ~ "p25_se",
        str_detect(name,"_p50_se$") ~ "p50_se",
        str_detect(name,"_p75_se$") ~ "p75_se",
        str_detect(name,"_p100_se$") ~ "p100_se",
        TRUE ~ NA_character_
      ),
      dataset = "oi"
    ) %>%
    select(-name) %>%
    select(
      dataset,state,county,year,
      race,gender,age_range,
      var_name,value,stat_type
    ) %>%
    distinct()
  
  # Write files 
  feather::write_feather(df,paste0("data/oi_files/oi_county_long_",i,".feather"))
  
}

stopCluster(cl)
rm(cl)
# Read each separate state file and append to database
# This assumes the existence of a system DSN named 'locals', which points to a db 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")

for (i in list.files("data/oi_files",full.names = T)){
  df <- feather::read_feather(i) %>% mutate(value = round(value,2))
  odbc::dbWriteTable(locals_db, "counties", df, append = T)
}

# Remove directory
unlink("data/oi_files", recursive = TRUE)
rm(oi_county)

# Transform covariate data
oi_covar <- feather::read_feather("data/oi_covar_tract.feather")

df <-
  oi_covar %>% 
  # filter(state == i) %>%
  mutate_all(~as.character(.)) %>%
  select(-cz,-czname) %>%
  pivot_longer(cols = -one_of("state","county","tract")) %>% 
  # Remove NA values for memory
  filter(!is.na(value)) %>%
  mutate(
    value = as.numeric(value),
    var_name = name,
    race = case_when(
      str_detect(name,"hisp_") ~ "hispanic",
      str_detect(name,"black_") ~ "black",
      str_detect(name,"white_") ~ "white",
      str_detect(name,"asian_") ~ "asian",
      str_detect(name,"natam_") ~ "natam",
      str_detect(name,"other_") ~ "other",
      TRUE ~ "pooled"
    ),
    gender = case_when(
      str_detect(name,"_male") ~ "male",
      str_detect(name,"_female") ~ "female",
      TRUE ~ "pooled"
    ),
    age_range = "pooled",
    year = NA_character_,
    stat_type = case_when(
      str_detect(name,"_mean") ~ "mean",
      str_detect(name,"^mean") ~ "mean",
      str_detect(name,"avg") ~ "mean",
      str_detect(name,"gsmn_math_g3_2013") ~ "mean",
      str_detect(name,"^med") ~ "median",
      str_detect(name,"rent_twobed2015") ~ "median",
      str_detect(name,"share") ~ "frac",
      str_detect(name,"^frac_") ~ "frac",
      str_detect(name,"density") ~ "frac",
      str_detect(name,"traveltime15_2010") ~ "frac",
      str_detect(name,"emp2000") ~ "frac",
      str_detect(name,"mail_return_rate2010") ~ "frac",
      str_detect(name,"jobs_total_5mi_2015") ~ "n",
      str_detect(name,"jobs_highpay_5mi_2015") ~ "n",
      str_detect(name,"ln_wage_growth_hs_grad") ~ "diff",
      TRUE ~ NA_character_
    ),
    dataset = "oi_covar"
  ) %>% 
  mutate(value = round(value,2)) %>%
  select(-name) %>%
  select(
    dataset,state,county,tract,year,
    race,gender,age_range,
    var_name,value,stat_type
  ) %>%
  distinct()

odbc::dbWriteTable(locals_db, "tracts", df, append = T)

rm(oi_covar); rm(df)
