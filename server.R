source("R/filter_vars_and_join_functions.R")
source("R/plot_functions.R")

server <- function(input, output, session) {
  # get user's sector
  sector <- reactive({
    input$user_sector
  })
  
  # update dataset input based on user's sector choice
  observeEvent(sector(), {
    updateSelectInput(
      input = "user_dataset",
      choices = names(dfs[[input$user_sector]])
      )
  })
  
  # get information from list of dfs
  dataset <- reactive(dfs[[input$user_sector]][[input$user_dataset]]$data)
  vars <- reactive(dfs[[input$user_sector]][[input$user_dataset]]$explorable_vars)
  plot_options <- reactive(dfs[[input$user_sector]][[input$user_dataset]]$plot_options)
  
  # dynamic input options - construct dropdowns
  # (see filter_vars_and_join_functions.R)
  output$dynamic_dropdowns <- renderUI(
    map(vars(), ~ make_dropdown(dataset()[[.x]], .x))
  )
  
  # update plot options based on user's dataset choices
  observeEvent(dataset(), {
    updateRadioButtons(
      input = "user_plot",
      choices = str_to_title(plot_options())
    )
  })
  
  # get user's plot choice
  plot_choice <- reactive({
    input$user_plot
  })
  
  # if plot choice is not line, set year to max year by default.
  # user can always change this.
  observe({
    if (plot_choice() != "Line") {
    updateSliderInput(
      input = "year",
      # cheat to set to max year
      value = 3000,
    )
    }
  })
  
  # get df of TRUES and FALSES to filter
  selected <- eventReactive(input$update, {
    each_var <- map(vars(), ~ filter_var(dataset()[[.x]], input[[.x]]))
    reduce(each_var, `&`)
  })
  
  # apply filtration
  selected_df <- eventReactive(input$update, {
    selected_df <- dataset()[selected(), ]
    
      if(input$user_plot == "Bar") {
        selected_df <- selected_df %>% 
          group_and_summarise_excluding(c("year", "value", "units"))
      } else if (input$user_plot == "Line") {
        selected_df <- selected_df %>% 
          group_and_summarise_including("year")
      }
    return(selected_df)
  })
  
  # create plot - see plot_functions.R
  plot <- eventReactive(input$update, {
    if (input$user_plot == "Line") {
      selected_df() %>% 
      create_line_plot()
    } else if (input$user_plot == "Bar") {
      selected_df() %>% 
        create_bar_plot()
    } else if(input$user_plot == "Sunburst") {
      selected_df() %>% 
        create_hierarchical_plot("Sunburst")
    } else if(input$user_plot == "Treemap") {
      selected_df() %>% 
        create_hierarchical_plot("Treemap")
    }
    
  })

  # render plot
  output$plot <- renderPlotly({
    plot()
  })
  
  # informative title  
  title_text <- eventReactive(input$update, {
    paste0("Selected: ", input$user_dataset)
  })

  output$title <- renderText(
    title_text()
  )

}
