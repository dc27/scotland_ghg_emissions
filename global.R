library(shiny)
library(shinydashboard)
library(readr)
library(dplyr)
library(readxl)
library(stringr)
library(ggplot2)

emissions_data <- read_csv("data/clean_data/ghg_emissions.csv")

pollutants <- unique(emissions_data$pollutant)

