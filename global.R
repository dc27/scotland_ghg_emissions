# required for shiny operation
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
# reading/data wrangling
library(readr)
library(dplyr)
library(tidyr)
library(readxl)
library(stringr)
library(purrr)
# data vis
library(ggplot2)
library(plotly)
library(viridis)

source("list_of_dfs.R")
source("dropdown_lookup.R")

dfs <- explorable_dfs

historical_emissions_data <- dfs$All$`Historic Emissions`$data

dropdown_lookup <- dropdown_lookup

# default plot options
theme_set(theme_bw())
theme_update(plot.title = element_text(hjust = 0.5))

options(ggplot2.continuous.colour="viridis")
options(ggplot2.continuous.fill = "viridis")
scale_fill_discrete <- function(...) {
  scale_fill_manual(..., values = c(viridis_pal()(9)))
} 

# to render images in app from the images folder:
myImgResources <- paste0("imgResources/", "sunburst_emissions", ".png")

# Add directory of static resources to Shiny's web server
addResourcePath(prefix = "imgResources", directoryPath = "images")

date_of_cop <- as.Date("2021-11-1")
