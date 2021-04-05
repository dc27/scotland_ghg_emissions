library(shiny)
library(shinydashboard)
library(readr)
library(dplyr)
library(readxl)

emissions_data <- read_xlsx("data/raw_data/scottish-ghg-dataset-2018.xlsx", 2)

