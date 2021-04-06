server <- function(input, output, session) {
  output$dropdowns <- renderUI({
      # convert snakecase variable name to title for ui
      varname <- str_to_title(str_replace_all(input$col_choice, "_", " "))
      selectInput(input$col_choice, varname, sort(unique(emissions_data[[input$col_choice]])))
  })
}
