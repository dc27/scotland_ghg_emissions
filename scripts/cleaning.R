library(tidyverse)
library(readxl)

emissions <- read_xlsx(
  "data/raw_data/2005-18-uk-local-regional-co2-emissions.xlsx", 2, skip = 1
  ) %>% 
  janitor::clean_names()


# filter for only scotland data and pivot to long form
emissions_scot <- emissions %>% 
  filter(second_tier_authority == "Scotland") %>% 
  rename(country = 1) %>% 
  select(-2) %>% 
  pivot_longer(
    -c(1,2,3,4, population_000s_mid_year_estimate, area_km2,
       per_capita_emissions_t, emissions_per_km2_kt),
    names_to = "emission_source_sector", values_to = "emissions")

# extract summary information
emissions_summary <- emissions_scot %>% 
  select(-c(emission_source_sector, emissions)) %>% 
  unique()

# and breakdown stats
emissions_long <- emissions_scot %>% 
  select(country, name, code, year, emission_source_sector, emissions)

# write clean files
emissions_summary %>% 
  write_csv("data/clean_data/scot_emissions_summary.csv")

emissions_long %>% 
  write_csv("data/clean_data/scot_emissions.csv")