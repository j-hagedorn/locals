

library(foreach); library(doParallel) 

n_cores <- detectCores()/2
cl <- parallel::makeCluster(2,type = 'SOCK', nnodes = n_cores)
registerDoParallel(cl)
# foreach(i=1:3) %dopar% sqrt(i)

n_states <- length(unique(oi_tract$state))

tst <- 
foreach (i = 1:n_states, .combine = rbind) %dopar% {
  library(tidyverse)
  memory.limit(30000)
  oi_tract %>% 
    filter(state == i) %>%
    mutate_all(~as.character(.)) %>%
    select(-cz,-czname) %>%
    pivot_longer(
      cols = -one_of("state","county","tract")
    ) %>% 
    # Remove NA values for memory
    filter(!is.na(value))
}
