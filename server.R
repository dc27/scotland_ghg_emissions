source("R/filter_vars_and_join_functions.R")
source("R/filter_vars_and_join_functions.R")

server <- function(input, output, session) {

  # dynamic ui
  # dataset <- reactive(dfs[[input$df_choice]]$data)
  # vars <- reactive(dfs[[input$df_choice]]$explorable_vars)
  # 
  # output$dropdowns <- renderUI(
  #   map(vars(), ~ make_dropdown(dataset(), .x))
  # )
  # 
  # # user inputs for dynamic vars
  # selected <- eventReactive(input$update, {
  #   each_var <- map(vars(), ~ filter_var(dataset()[[.x]], input[[.x]]))
  #   reduce(each_var, `&`)
  # })
  
  # filter df
  selected_df <- eventReactive(input$update, {
      dataset()[selected(), ]
  })
  
  # get units
  units <- eventReactive(input$update, {
    potential_units <- unique(selected_df()$units)
    # remove NAs, select first value in the case where multiple are provided.
    potential_units[!is.na(potential_units)][1]
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


  plot_spdf <- eventReactive(input$update, {
    join_with_shapes(selected_df(), la_shapes)
  })
  
  observeEvent(input$update, {
    # dev/testing! - this is a good spot for a break-point
    if (nrow(selected_df()) == 0) {
      # no data label
      leafletProxy("scotland_map") %>% 
        clearShapes() %>% 
        clearMarkers() %>% 
        addLabelOnlyMarkers(
          lng = -5, lat = 58,
          label = "No Data",
          labelOptions = labelOptions(noHide = T, textsize = "32px")
        )
    } else {
      add_coloured_polygons(
        basemap = "scotland_map", spdf = plot_spdf(),
        units = units()
      )
    }
  })
  
  # plot legend
  observeEvent(input$update, {
    leafletProxy("scotland_map") %>%
      clearControls()
    
    if (input$legend & nrow(selected_df())!=0)  {
      add_legend(
        "scotland_map", spdf = plot_spdf(),
        units = units()
      )}
  })
}
