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
      group_by_(input$col_choice, "emission_year") %>% 
      summarise(total_ghg_emissions = sum(emissions)) %>%
      ggplot() +
      aes_string(x = "emission_year", y = "total_ghg_emissions", group = input$col_choice, colour = input$col_choice) +
      geom_line() +
      geom_point() +
      scale_x_continuous(breaks = seq(1990,2020,5)) +
      theme_bw()
  })
}
