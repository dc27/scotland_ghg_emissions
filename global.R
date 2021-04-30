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

