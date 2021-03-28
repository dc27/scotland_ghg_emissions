library(tidyverse)
library(readxl)

emissions <- read_xlsx(
  "data/raw_data/2005-18-uk-local-regional-co2-emissions.xlsx", 2, skip = 1
  ) %>% 
  janitor::clean_names()


# filter for only Scotland data and pivot to long form
emissions_scot <- emissions %>% 
  select(-1) %>% 
  filter(second_tier_authority == "Scotland")

# extract totals information
emissions_totals <- emissions_scot %>% 
  select(c(1,2,3,4, industry_and_commercial_total, 
           domestic_total, transport_total, lulucf_net_emissions,grand_total)) %>% 
  select(-1) %>% 
  pivot_longer(-c(1,2,3), names_to = "emissions_sector", values_to = "value") %>% 
  mutate(emissions_sector = str_remove(emissions_sector,
                                       "_total$|_net_emissions$")) %>% 
  mutate(emissions_sector = str_to_title(
    str_replace_all(emissions_sector, "_", " "))
    ) %>% 
  mutate(emissions_sector = ifelse(emissions_sector == "Lulucf", "LULUCF", emissions_sector)) %>% 
  mutate(units = "kilotonnes")

# extract local authority information (unrelated to C02 but used in future calcs)
la_info <- emissions_scot %>% 
  select(c(1,2,3,4, population_000s_mid_year_estimate, area_km2))

# extract breakdown info for subsectors
emissions_breakdown <- emissions_scot %>%
  select(c(1,2,3,4, matches("^[a-z]_"))) %>% 
  pivot_longer(-c(1,2,3,4), names_to = "emissions_sector_subsector",
               values_to = "value") %>% 
  mutate(emissions_sector = case_when(
    str_detect(emissions_sector_subsector, "^[a-e]_") ~ "Industry and Commercial",
    str_detect(emissions_sector_subsector, "^[f-h]_") ~ "Domestic",
    str_detect(emissions_sector_subsector, "^[i-m]_") ~ "Transport",
    str_detect(emissions_sector_subsector, "^[n-s]_") ~ "LULUCF",
    TRUE ~ NA_character_
  ), .before = "emissions_sector_subsector") %>% 
  mutate(emissions_sector_subsector = str_to_title(
    str_replace_all(emissions_sector_subsector, "_", " "))
  ) %>%
  mutate(units = "kilotonnes")

# write clean files
emissions_totals %>% 
  write_csv("data/clean_data/scot_emissions_summary.csv")

emissions_breakdown %>% 
  write_csv("data/clean_data/scot_emissions.csv")

la_info %>% 
  write_csv("data/clean_data/la_info.csv")