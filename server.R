# source("R/plot_functions.R")

server <- function(input, output, session) {
  # render basemap
  output$scotland_map <- renderLeaflet({
    leaflet(options = leafletOptions(minZoom = 7)) %>%
      setView(lng = -5, lat = 56, zoom = 7) %>%
      # restrict view to around Scotland
      setMaxBounds(lng1 = -1,
                   lat1 = 54,
                   lng2 = -9,
                   lat2 = 63) %>% 
      addProviderTiles(providers$Esri.WorldGrayCanvas)
  })
}