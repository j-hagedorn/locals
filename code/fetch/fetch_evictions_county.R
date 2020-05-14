
fetch_evictions_county <- function(){
  
  library(tidyverse); library(aws.s3)
  
  # Get df of assets in AWS bucket
  contents <- 
    get_bucket_df(bucket = 'eviction-lab-data-downloads') %>%
    filter(str_detect(Key,"counties.csv"))
  
  # Loop and combine
  df <- tibble()
  
  for(i in 1:nrow(contents)){
    
    x <- 
      get_object(
        contents$Key[1], contents$Bucket[1], as = "text"
      ) %>%
      read_csv() %>%
      mutate_all(list(~as.character(.)))
    
    df <- df %>% bind_rows(x)
    
  }
  
  rm(i); rm(contents)
  
  return(df)
  
}


# evictions_county <- fetch_evictions_county()