library(shiny)
library(shinydashboard)
library(readr)
library(dplyr)
library(leaflet)
library(rgdal)

la_shapes <- readOGR(
  dsn = "data/shapefiles/la/scottish_local_authorities",
  layer = "scottish_local_authorities",
  GDAL1_integer64_policy = TRUE
)