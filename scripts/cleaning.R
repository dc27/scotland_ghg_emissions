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
  unique() %>% 
  pivot_longer(-c(1,2,3,4), names_to = "statistic", values_to = "value")

# filter for summary info, add units
emissions_summary <- emissions_summary %>% 
  mutate(statistic = str_to_title(str_replace_all(statistic,"_", " "))) %>% 
  mutate(statistic = case_when(
    statistic == "Per Capita Emissions T" ~ "Emissions per Capita",
    statistic == "Emissions Per Km2 Kt" ~ "Emissions per Km2",
    TRUE ~ statistic
  )) %>% 
  filter(statistic == "Emissions per Capita"|
           statistic == "Emissions per Km2") %>% 
  mutate(units = case_when(
    statistic == "Emissions per Capita" ~ "tonnes",
    statistic == "Emissions per Km2" ~ "kilotonnes"
  ))

# and breakdown stats
emissions_long <- emissions_scot %>% 
  select(country, name, code, year, emission_source_sector, emissions) %>% 
  mutate(emission_source_sector = str_to_title(str_replace_all(emission_source_sector, "_", " "))) %>% 
  mutate(units = "kilotonnes")

# write clean files
emissions_summary %>% 
  write_csv("data/clean_data/scot_emissions_summary.csv")

emissions_long %>% 
  write_csv("data/clean_data/scot_emissions.csv")