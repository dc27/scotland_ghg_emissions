library(tidyverse)
library(readxl)
library(readODS)

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

# summary info
ghg_emissions_clean %>% 
  group_by(ccp_mapping, pollutant, year) %>% 
  summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>% 
  mutate(units = ghg_emissions_clean$units[1]) %>% 
  write_csv("data/clean_data/ghg_emissions_summary.csv")

# ----- hierarchical data -----

# get number of separators in source column
n_breaks <- max(str_count(ghg_emissions_clean$source_name, " - "), na.rm = TRUE)

# number of potential children  = number of breaks + 1
# since: "one" - "two" - "three"
n_children <- n_breaks + 1

# create vector and fill with childnames
child_names <- c()

for (i in seq(1:n_children)) {
  child_name <- paste("child_order_", i, sep = "")
  child_names <- c(child_names, child_name)
}

# clean source name column and split into child columns
ghg_wide <- ghg_emissions_clean %>% 
  mutate(source_name = str_to_title(
    str_remove(
      source_name,
      paste("^", ccp_mapping, " - ", sep = "")
    ))) %>% 
  mutate(ccp_mapping = str_to_title(ccp_mapping)) %>% 
  separate(source_name, into = child_names, sep = " - ", fill = "right") %>% 
  rename(child_order_0 = ccp_mapping)

# split data for true emissions and sinks (combine after creating children)

ghg_wide_emissions <- ghg_wide %>%
  filter(!value < 0)

ghg_wide_sinks <- ghg_wide %>% 
  filter(value < 0)

# emissions

child_order_0 <- ghg_wide_emissions %>% 
  group_by(child_order_0, pollutant, year) %>% 
  summarise(value = sum(value), .groups = "drop_last") %>% 
  # id must be created, parents are null - this is the top level
  mutate(id = child_order_0, parent = "") %>% 
  select(id, label = child_order_0, parent, pollutant, year, value)

child_order_1 <- ghg_wide_emissions %>%
  group_by(child_order_1, child_order_0, pollutant, year) %>% 
  summarise(value = sum(value), .groups = "drop") %>% 
  mutate(id = paste(child_order_0, child_order_1, sep = " - "),
         parent = child_order_0) %>% 
  select(id, label = child_order_1, parent, pollutant, year, value)

child_order_2 <- ghg_wide_emissions %>%
  filter(!is.na(child_order_2)) %>% 
  group_by(child_order_2, child_order_1, child_order_0, pollutant, year) %>% 
  summarise(value = sum(value), .groups = "drop") %>% 
  mutate(id = paste(child_order_0, child_order_1, child_order_2, sep = " - "),
         parent = paste(child_order_0, child_order_1, sep = " - ")) %>% 
  select(id, label = child_order_2, parent, pollutant, year, value)

child_order_3 <- ghg_wide_emissions %>%
  filter(!is.na(child_order_3)) %>% 
  group_by(child_order_3, child_order_2, child_order_1, child_order_0, pollutant, year) %>% 
  summarise(value = sum(value), .groups = "drop") %>% 
  mutate(id = paste(child_order_0, child_order_1, child_order_2, child_order_3, sep = " - "),
         parent = paste(child_order_0, child_order_1, child_order_2, sep = " - ")) %>% 
  select(id, label = child_order_3, parent, pollutant, year, value)

ghg_long_emissions <- bind_rows(list(child_order_0, child_order_1, child_order_2, child_order_3))

# sinks

child_order_0 <- ghg_wide_sinks %>% 
  group_by(child_order_0, pollutant, year) %>% 
  summarise(value = sum(value), .groups = "drop_last") %>% 
  # id must be created, parents are null - this is the top level
  mutate(id = child_order_0, parent = "") %>% 
  select(id, label = child_order_0, parent, pollutant, year, value)

child_order_1 <- ghg_wide_sinks %>%
  group_by(child_order_1, child_order_0, pollutant, year) %>% 
  summarise(value = sum(value), .groups = "drop") %>% 
  mutate(id = paste(child_order_0, child_order_1, sep = " - "),
         parent = child_order_0) %>% 
  select(id, label = child_order_1, parent, pollutant, year, value)

child_order_2 <- ghg_wide_sinks %>%
  filter(!is.na(child_order_2)) %>% 
  group_by(child_order_2, child_order_1, child_order_0, pollutant, year) %>% 
  summarise(value = sum(value), .groups = "drop") %>% 
  mutate(id = paste(child_order_0, child_order_1, child_order_2, sep = " - "),
         parent = paste(child_order_0, child_order_1, sep = " - ")) %>% 
  select(id, label = child_order_2, parent, pollutant, year, value)

# not run as data only goes up to 2 child order
child_order_3 <- ghg_wide_sinks %>%
  filter(!is.na(child_order_3)) %>% 
  group_by(child_order_3, child_order_2, child_order_1, child_order_0, pollutant, year) %>%
  summarise(value = sum(value), .groups = "drop") %>%
  mutate(id = paste(child_order_0, child_order_1, child_order_2, child_order_3, sep = " - "),
         parent = paste(child_order_0, child_order_1, child_order_2, sep = " - ")) %>%
  select(id, label = child_order_3, parent, pollutant, year, value)

ghg_long_sinks <- bind_rows(list(child_order_0, child_order_1, child_order_2))


# all together
ghg_hierchary <- bind_rows(list(ghg_long_emissions, ghg_long_sinks)) %>% 
  mutate(units = "megatonnes of co2 equivelant")

ghg_hierchary %>% 
  write_csv("data/clean_data/hierarchical_data.csv")


# ----- new ulevs -----

# new registrations for each vehicle type come from different files - must
# be brought together before cleaning
new_ulevs <- read_xlsx("data/raw_data/transport/new_ulevs.xlsx", skip = 1)

new_ulevs_long <- new_ulevs %>% 
  janitor::clean_names() %>% 
  pivot_longer(-1, names_to = "ulev_type", values_to = "n_registered") %>% 
  mutate(ulev_type = str_replace(ulev_type, "all_", ""))

new_cars <- read_ods("data/raw_data/transport/new_cars.ods", skip = 6)

new_cars_scot <- new_cars %>% 
  janitor::clean_names() %>%
  head(20) %>% 
  select(year, scotland)

new_cars_scot <- new_cars_scot[-c(1),] %>% 
  mutate(scotland = scotland * 1000) %>% 
  rename(cars = scotland)

new_motorbikes <- read_ods("data/raw_data/transport/new_motorcycles.ods", skip = 6)

extract_scotland <- function(df) {
  df[-c(1),] %>% 
    janitor::clean_names() %>% 
    head(20) %>% 
    select(year, scotland) %>% 
    mutate(scotland = scotland * 1000)
}

new_motorbikes_scot <- new_motorbikes %>% 
  extract_scotland() %>% 
  rename(motorcycles_and_tricycles = scotland)

new_lgvs <- read_ods("data/raw_data/transport/new_lgvs.ods", skip = 6)

new_lgvs_scot <- new_lgvs %>% 
  extract_scotland() %>% 
  rename(lgvs = scotland)

new_hgvs <- read_ods("data/raw_data/transport/new_hgvs.ods", skip = 6)

new_hgvs_scot <- new_hgvs %>% 
  extract_scotland() %>% 
  rename(hgvs = scotland)

new_buses <- read_ods("data/raw_data/transport/new_buses_coaches.ods", skip = 6)

new_buses_scot <- new_buses %>% 
  extract_scotland() %>% 
  rename(buses_and_coaches = scotland)

new_vehicles_scot <-
  new_cars_scot %>% 
  left_join(new_motorbikes_scot, by = "year") %>% 
  left_join(new_lgvs_scot, by = "year") %>% 
  left_join(new_hgvs_scot, by = "year") %>% 
  left_join(new_buses_scot, by = "year") %>% 
  rename(light_goods_vehicles = lgvs,
         heavy_goods_vehicles = hgvs) %>% 
  pivot_longer(-1, names_to = "vehicle_type", values_to = "n_registered")

new_vehicles_scot <- new_vehicles_scot %>% 
  mutate(year = as.numeric(ifelse(year == "2018r", "2018", year))) %>%
  inner_join(new_ulevs_long, by = c("year" = "year", "vehicle_type" = "ulev_type")) %>% 
  rename(n_registered = n_registered.x,
         n_ulevs_registered = n_registered.y)

new_vehicles_scot %>%
  mutate(vehicle_type = str_to_title(str_replace_all(vehicle_type, "_", " "))) %>%
  pivot_longer(cols = c(n_registered, n_ulevs_registered), names_to = "statistic", values_to = "value") %>% 
  mutate(statistic = recode(statistic,
                            "n_registered" = "Vehicle Registrations",
                            "n_ulevs_registered" = "ULE Vehicle Registrations",
  )) %>% 
  mutate(units = statistic) %>% 
  write_csv("data/clean_data/newly_registered_vehicles_and_ulevs.csv")