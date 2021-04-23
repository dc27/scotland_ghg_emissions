library(tidyverse)
library(readxl)

emissions <- read_xlsx(
  "data/raw_data/2005-18-uk-local-regional-co2-emissions.xlsx", 2, skip = 1
  ) %>% 
  janitor::clean_names()


# filter for only Scotland data and pivot to long form
ghg_emissions_data <- read_xlsx("data/raw_data/scottish-ghg-dataset-2018.xlsx", 2)

ghg_emissions_clean <- ghg_emissions_data %>% 
  janitor::clean_names() %>% 
  mutate(units = "megatonnes of co2 equivelant") %>% 
  rename(emissions = emissions_mt_co2e) %>% 
  filter(emission_year != "BaseYear") %>% 
  mutate(emission_year = as.numeric(emission_year)) %>% 
  select(ccp_mapping, source_name, pollutant, year = emission_year, value = 
           emissions, units)

ghg_emissions_clean %>% 
  write_csv("data/clean_data/ghg_emissions.csv")