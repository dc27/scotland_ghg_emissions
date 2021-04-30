library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(readr)
library(dplyr)
library(readxl)
library(stringr)
library(ggplot2)
library(plotly)

emissions_data <- read_csv("data/clean_data/ghg_emissions.csv")

years <- unique(emissions_data$year)
pollutants <- unique(emissions_data$pollutant)

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