library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(readr)
library(dplyr)
library(purrr)
library(leaflet)
library(rgdal)

dfs <- list(
  "emissions_breakdown" = list(
    data = read_csv("data/clean_data/scot_emissions.csv"),
    explorable_vars = c("year", "emissions_sector_subsector")
  )
)

sectors <- unique(dfs$emissions_breakdown$data$emissions_sector)

subsectors <- list()

for (sector in sectors) {
  subsectors[[sector]] <- dfs$emissions_breakdown$data %>% 
    select(emissions_sector, emissions_sector_subsector) %>% 
    filter(emissions_sector == sector) %>% 
    distinct(emissions_sector_subsector) %>% 
    pull()
}

years <- sort(unique(dfs$emissions_breakdown$data$year))

la_shapes <- readOGR(
  dsn = "data/shapefiles/la/scottish_local_authorities",
  layer = "scottish_local_authorities",
  GDAL1_integer64_policy = TRUE
)


