library(shiny)
library(shinydashboard)
library(readr)
library(dplyr)
library(leaflet)
library(rgdal)

dfs <- list(
  "Standardised Emissions" = list(
    data = read_csv("data/clean_data/scot_emissions_summary.csv"),
    explorable_vars = c("year", "per_captia_emissions_t",
                        "emissions_per_km2_kt")
  ),
  "Raw Emissions" = list(
    data = read_csv("data/clean_data/scot_emissions.csv"),
    explorable_vars = c("year", "emissions_source_sector")
  )
)

la_shapes <- readOGR(
  dsn = "data/shapefiles/la/scottish_local_authorities",
  layer = "scottish_local_authorities",
  GDAL1_integer64_policy = TRUE
)