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
  
  summarised_data <- reactive({
    emissions_data %>% 
      group_by_(input$col_choice, "emission_year") %>% 
      summarise(total_ghg_emissions = sum(emissions))
  })
  
  
  output$emission_graph <- renderPlot({
    p <- summarised_data() %>%
      ggplot() +
      aes_string(x = "emission_year", y = "total_ghg_emissions", group = input$col_choice, colour = input$col_choice, fill = input$col_choice) +
      scale_x_continuous(breaks = seq(1990,2020,5)) +
      theme_bw() +
      theme(text = element_text(size=20))
    
    if (input$plot_choice == "Area") {
      p <- p() +
        geom_area(alpha = 0.6)
    } else if (input$plot_choice == "Line") {
      p <- p() +
        geom_line(size = 1.2) +
        geom_point(size = 2.5)
    } else {
      p <- p() +
        geom_point(size = 2)
      
    }

  })
}
