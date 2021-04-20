library(shiny)
library(shinydashboard)
library(readr)
library(dplyr)
library(readxl)
library(stringr)
library(ggplot2)
library(plotly)

emissions_data <- read_csv("data/clean_data/ghg_emissions.csv")

years <- unique(emissions_data$year)
pollutants <- unique(emissions_data$pollutant)

