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

myImgResources <- paste0("imgResources/", "sunburst_emissions", ".png")

# Add directory of static resources to Shiny's web server
addResourcePath(prefix = "imgResources", directoryPath = "images")
