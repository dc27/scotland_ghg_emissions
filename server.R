source("R/filter_vars_and_join_functions.R")
source("R/plot_functions.R")

server <- function(input, output, session) {
  
  # ----- navigation -----
  
  observeEvent(input$goto_emissions_explorer, {
    updateTabsetPanel(session, "inTabset",
                      selected = "emissions")
  })
  
  
  observeEvent(input$goto_targets_explorer, {
    updateTabsetPanel(session, "inTabset",
                      selected = "targets")
  })
  
  
  observeEvent(input$goto_choices_explorer, {
    updateTabsetPanel(session, "inTabset",
                      selected = "choices")
  })
  
  observeEvent(input$return_home_1, {
    updateTabsetPanel(session, "inTabset",
                      selected = "home")
  })
  
  observeEvent(input$return_home_2, {
    updateTabsetPanel(session, "inTabset",
                      selected = "home")
  })
  
  observeEvent(input$return_home_3, {
    updateTabsetPanel(session, "inTabset",
                      selected = "home")
  })
  
  # ----- dynamic ui -----
  
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
  
  observe({
    if(input$user_dataset == "Newly Registered ULEVs"){
      show("p_new_ulevs")
    }else{
      hide("p_new_ulevs")
    }
  })
  
  # get user's plot choice
  plot_choice <- reactive({
    input$user_plot
  })
  
  # if plot choice is not line, set year to max year by default.
  # user can always change this.
  observe({
    if (!plot_choice() %in% c("Line", "Area")) {
    updateSliderInput(
      input = "year",
      # cheat to set to max year
      value = 3000,
    )
    }
  })
  
  
  
  # ---- filter data -----
  # get df of TRUES and FALSES to filter
  selected <- eventReactive(input$update, {
    each_var <- map(vars(), ~ filter_var(dataset()[[.x]], input[[.x]]))
    reduce(each_var, `&`)
  })
  
  # apply filtration
  selected_df <- eventReactive(input$update, {
    selected_df <- dataset()[selected(), ]
    
    # TODO:: percentages need a bit of work
    if (input$user_dataset == "Newly Registered ULEVs" & input$p_new_ulevs) {
      selected_df <- dataset() %>% 
        filter(vehicle_type %in% input$vehicle_type) %>% 
        filter(year >= input$year[1] & year <= input$year[2]) %>% 
        group_and_summarise_including(c("year", "statistic")) %>% 
        mutate(perc_new_ulevs = lag(value)/value *100) %>% 
        mutate(units = "% newly registered vehicles are ULEV") %>% 
        select(- c(statistic, value)) %>% 
        drop_na() %>% 
        select(year, value = perc_new_ulevs, units)
    } else if(input$user_plot == "Bar") {
        selected_df <- selected_df %>% 
          group_and_summarise_excluding(c("pollutant", "year", "value", "units"))
    } else if (input$user_plot == "Line") {
        selected_df <- selected_df %>% 
          group_and_summarise_including("year")
    } else if (input$user_plot == "Area") {
        selected_df <- selected_df %>% 
          group_and_summarise_excluding(c("pollutant", "value", "units"))
    }
    
    return(selected_df)
  })
  
  
  # ----- create plot ------
  # see plot_functions.R
  plot <- eventReactive(input$update, {
    if (input$user_plot == "Line") {
      selected_df() %>% 
        create_line_plot() + labs(y = selected_df()$units[1])
    } else if (input$user_plot == "Bar") {
      selected_df() %>% 
        create_bar_plot() + labs(y = selected_df()$units[1])
    } else if (input$user_plot == "Area") {
      selected_df() %>% 
        create_area_plot() + labs(y = selected_df()$units[1])
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
  
  hierarchy_emissions_2018 <-  dfs$All$`Sector Breakdown`$data %>% 
    filter(year == 2018)

  emissions_plot <- create_hierarchical_plot(df = hierarchy_emissions_2018)
  sinks_plot <- create_hierarchical_plot(df = hierarchy_emissions_2018,
                                         sinks = TRUE)
  
  output$emissions_plot <- renderPlotly(
    emissions_plot
  )
  
  output$sinks_plot <- renderPlotly(
    sinks_plot
  )
}
