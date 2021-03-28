# source("R/plot_functions.R")
source("R/filter_vars_and_join_functions.R")


server <- function(input, output, session) {

  # dynamic ui
  dataset <- reactive(dfs[[input$df_choice]]$data)
  vars <- reactive(dfs[[input$df_choice]]$explorable_vars)
  
  output$dropdowns <- renderUI(
    map(vars(), ~ make_dropdown(dataset(), .x))
  )
  
  # user inputs for dynamic vars
  selected <- eventReactive(input$update, {
    each_var <- map(vars(), ~ filter_var(dataset()[[.x]], input[[.x]]))
    reduce(each_var, `&`)
  })
  
  
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