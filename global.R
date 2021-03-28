library(shiny)
library(shinydashboard)
library(readr)
library(dplyr)
library(purrr)
library(leaflet)
library(rgdal)

dfs <- list(
  "Sector Totals" = list(
    data = read_csv("data/clean_data/scot_emissions_summary.csv"),
    explorable_vars = c("year", "emissions_sector")
  ),
  "Multi-select" = list(
    data = read_csv("data/clean_data/scot_emissions.csv"),
    explorable_vars = c("year", "emissions_sector_subsector")
  )
)

la_shapes <- readOGR(
  dsn = "data/shapefiles/la/scottish_local_authorities",
  layer = "scottish_local_authorities",
  GDAL1_integer64_policy = TRUE
)