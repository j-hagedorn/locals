library(tidyverse)

source("code/fetch/fetch_oi_tract.R")

oi_tract <- fetch_oi_tract()

oe_mi <- oi_tract %>% filter(state == 26)

oe_mi_long <- 
  oe_mi %>% 
  mutate_all(~as.character(.)) %>%
  pivot_longer(
    cols = -one_of("state","county","tract","cz","czname")
  ) %>%
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
    )
  ) %>%
  select(-name) %>%
  distinct() %>%
  pivot_wider(
    names_from = stat_type,
    values_from = value
  )


##The michigan state has 2813 tract locations but in the tract_outcomes_early file has 2061 tract locations.

feather::write_feather(oe_mi_long,"data/oe/oe_mi_long.feather")
