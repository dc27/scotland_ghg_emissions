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

# summary info
ghg_emissions_clean %>% 
  group_by(ccp_mapping, pollutant, year) %>% 
  summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>% 
  mutate(units = ghg_emissions_clean$units[1]) %>% 
  write_csv("data/clean_data/ghg_emissions_summary.csv")

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
