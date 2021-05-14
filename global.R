library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
library(readr)
library(dplyr)
library(tidyr)
library(readxl)
library(stringr)
library(ggplot2)
library(purrr)
library(plotly)

source("list_of_dfs.R")
source("dropdown_lookup.R")

dfs <- explorable_dfs

dropdown_lookup <- dropdown_lookup

theme_set(theme_bw())


emissions_data <- read_csv("data/clean_data/ghg_emissions.csv")

years <- sort(unique(emissions_data$year))
pollutants <- unique(emissions_data$pollutant)
sectors <- sort(unique(emissions_data$ccp_mapping))


hierarchical_emissions <- read_csv("data/clean_data/hierarchical_data.csv")

# filtered for only relating to transport
transport_hierarchy <- hierarchical_emissions %>% 
  filter(str_detect(id, "^Transport")) %>% 
  filter(!value < 0)

road_traffic <- read_csv("data/clean_data/transport/road_traffic.csv")

vehicle_types <- unique(road_traffic$vehicle_type)

new_ulevs <- read_csv(
  "data/clean_data/transport/newly_registered_vehicles_and_ulevs.csv"
  )

body_types <- unique(new_ulevs$body_type)





