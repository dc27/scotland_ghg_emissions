server <- function(input, output, session) {
  output$dropdowns <- renderUI({
      # convert snakecase variable name to title for ui
      varname <- str_to_title(str_replace_all(input$col_choice, "_", " "))
      selectInput(input$col_choice, varname,
                  sort(unique(emissions_data[[input$col_choice]])))
  })
  
  output$test_text <- renderText({
    input[[input$col_choice]]
  })
  
  output$emission_graph <- renderPlot({
    emissions_data %>% 
      filter(EmissionYear != "BaseYear") %>% 
      mutate(EmissionYear = as.numeric(EmissionYear)) %>% 
      group_by(EmissionYear, input$col_choice) %>% 
      summarise(total_ghg_emissions = sum(`Emissions (MtCO2e)`)) %>% 
      ggplot() +
      aes(x = EmissionYear, y = total_ghg_emissions) +
      geom_line() +
      geom_point() +
      scale_x_continuous(breaks = seq(1990,2020,5)) +
      ylim(0, 80) +
      theme(legend.position = 0) +
      theme_bw()
  })
}
