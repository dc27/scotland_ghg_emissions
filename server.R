source("R/filter_vars_and_join_functions.R")
source("R/plot_functions.R")

server <- function(input, output, session) {
  
  # ----- navigation -----
  
  observeEvent(input$goto_emissions_explorer, {
    updateTabsetPanel(session, "inTabset",
                      selected = "emissions")
  })
  
  observeEvent(input$goto_transport, {
    updateTabsetPanel(session, "inTabset",
                        selected = "transport")
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
  
  observeEvent(input$return_home_transport, {
    updateTabsetPanel(session, "inTabset",
                      selected = "home")
  })
  
  # ----- dynamic ui -----
  
  # get user's sector
  sector <- reactive({
    input$inTabset %>% 
      str_to_title()
  })
  
  observe({
  
    if (sector() != "Home" & sector() != "Emissions") {

      # TODO:: instead of multiple plots - create one at a time - if statements?
      # # update plot options based on user's dataset choices
      # observeEvent(dataset(), {
      #   updateRadioButtons(
      #     input = "user_plot",
      #     choices = str_to_title(plot_options())
      #   )
      # })
      # 
      # # observe({
      # #   if(input$user_dataset == "Newly Registered ULEVs"){
      # #     show("p_new_ulevs")
      # #   }else{
      # #     hide("p_new_ulevs")
      # #   }
      # # })
      # 
      # # # get user's plot choice
      # # plot_choice <- reactive({
      # #   input$user_plot
      # # })
      # 
      # # # if plot choice is not line, set year to max year by default.
      # # # user can always change this.
      # # observe({
      # #   if (!plot_choice() %in% c("Line", "Area")) {
      # #   updateSliderInput(
      # #     input = "year",
      # #     # cheat to set to max year
      # #     value = 3000,
      # #   )
      # #   }
      # # })
      # 
      # 
      # 
      # ---- filter data -----
      


    
      
      #   
      #   # TODO:: percentages need a bit of work
      #   if (input$user_dataset == "Newly Registered ULEVs" & input$p_new_ulevs) {
      #     selected_df <- dataset() %>% 
      #       filter(vehicle_type %in% input$vehicle_type) %>% 
      #       filter(year >= input$year[1] & year <= input$year[2]) %>% 
      #       group_and_summarise_including(c("year", "statistic")) %>% 
      #       mutate(perc_new_ulevs = lag(value)/value *100) %>% 
      #       mutate(units = "% newly registered vehicles are ULEV") %>% 
      #       select(- c(statistic, value)) %>% 
      #       drop_na() %>% 
      #       select(year, value = perc_new_ulevs, units)
      #   } else if(input$user_plot == "Bar") {
      #       selected_df <- selected_df %>% 
      #         group_and_summarise_excluding(c("pollutant", "year", "value", "units"))
      #   } else if (input$user_plot == "Line") {
      #       selected_df <- selected_df %>% 
      #         group_and_summarise_including("year")
      #   } else if (input$user_plot == "Area") {
      #       selected_df <- selected_df %>% 
      #         group_and_summarise_excluding(c("pollutant", "value", "units"))
      #   }
      #   
      #   return(selected_df)
      # })
      # 
      # 
      # # ----- create plot ------
      # # see plot_functions.R
      # plot <- eventReactive(input$update, {
      #   if (input$user_plot == "Line") {
      #     selected_df() %>% 
      #       create_line_plot() + labs(y = selected_df()$units[1])
      #   } else if (input$user_plot == "Bar") {
      #     selected_df() %>% 
      #       create_bar_plot() + labs(y = selected_df()$units[1])
      #   } else if (input$user_plot == "Area") {
      #     selected_df() %>% 
      #       create_area_plot() + labs(y = selected_df()$units[1])
      #   } else if(input$user_plot == "Sunburst") {
      #     selected_df() %>% 
      #       create_hierarchical_plot("Sunburst")
      #   } else if(input$user_plot == "Treemap") {
      #     selected_df() %>% 
      #       create_hierarchical_plot("Treemap")
      #   }
      #   
      # })
      # 
      # # render plot
      # output$plot <- renderPlotly({
      #   plot()
      # })
      # 
      # # informative title  
      # title_text <- eventReactive(input$update, {
      #   paste0("Selected: ", input$user_dataset)
      # })
      # 
      # output$title <- renderText(
      #   title_text()
      # )
      
      
      # ----- Transport -----
      # current_tab <- reactive({input$transport_nav})
      # 
      # 
      # dataset <- reactive({dfs[[sector()]][[current_tab()]]$data})
      # vars <- reactive({dfs[[sector()]][[current_tab()]]$explorable_vars})
      # 
      # # dynamic input options - construct dropdowns
      # # (see filter_vars_and_join_functions.R)
      # dropdowns <- map(vars(), ~ make_dropdown(dataset()[[.x]], .x))
      # 
      # output$dynamic_dropdowns <- renderUI(
      #   dropdowns
      # )

      observeEvent(
        input$transport_nav,
        priority = 1,
        {
          
          current_tab <- input$transport_nav
          
          dataset <<- dfs[[sector()]][[current_tab]]$data
          ex_vars <<- dfs[[sector()]][[current_tab]]$explorable_vars
          
          dropdowns <- map(ex_vars, ~make_dropdown(dataset[[.x]], .x))
          
          output$dynamic_dropdowns <- renderUI (
            dropdowns
          )
        })
      
      
      observeEvent(
        input$transport_nav,
        priority = 0,
        {
          each_var <- map(ex_vars, ~ filter_var(dataset[[.x]], input[[.x]]))
          selected <- reduce(each_var, `&`)
          
          req(selected)
          # apply filtration
          
          selected_df <- dataset[selected, ] %>%
            group_and_summarise_including("year")
          
          transport_plt <<- selected_df %>%
            create_line_plot(plt_title = input$transport_nav)
          
          output$new_ulevs <- renderPlotly(
            {
              req(transport_plt)
              transport_plt
            })
          
          
          # road traffic
          output$road_traffic <- renderPlotly(
            {
              transport_plt
            })
        }
      )
          

      observeEvent(
        input$update_transport_plt,
        priority = 1,
        {
          # get df of TRUEs and FALSEs to filter
          
          each_var <- map(ex_vars, ~ filter_var(dataset[[.x]], input[[.x]]))
          selected <- reduce(each_var, `&`)
          
          req(selected)
            # apply filtration
            
          selected_df <- dataset[selected, ] %>%
            group_and_summarise_including("year")
          
          transport_plt <<- selected_df %>%
            create_line_plot(plt_title = input$transport_nav)
          
          output$new_ulevs <- renderPlotly(
            {
              req(transport_plt)
              transport_plt
            })
          
          
          # road traffic
          output$road_traffic <- renderPlotly(
            {
              transport_plt
            })
        })
      

      
      dirty_default <- reactive({
        if (input$transport_nav == "Newly Registered ULEVs") {
        dirty_default <- dfs$Transport$`Newly Registered ULEVs`$data %>% 
          filter(statistic == "Vehicle Registrations") %>% 
          group_and_summarise_including("year") %>% 
          create_line_plot(plt_title = input$transport_nav)
        } else if (input$transport_nav == "Road Traffic") {
          dirty_default <- dfs$Transport$`Road Traffic`$data %>% 
            group_and_summarise_including("year") %>% 
            create_line_plot(plt_title = input$transport_nav)
        }
      })
        
          
      output$new_ulevs <- renderPlotly(
        {
          dirty_default()
        })


      # road traffic
      output$road_traffic <- renderPlotly(
        {
          dirty_default()
        })


      
    } else if (sector() == "Home") {
        
    
      # ----- homepage rendering -----
      # static
      #TODO::rename these variables
      
      home_line_plot <- historical_emissions_data %>% 
          group_and_summarise_including("year") %>% 
          create_line_plot(plt_title = "Annual Net Emissions in Scotland")
      
      output$headline_plot <- renderPlotly(
        home_line_plot
      )
      
      #infoboxes
      #emissions at min and max year
      end_values <- historical_emissions_data %>% 
        group_and_summarise_including("year") %>% 
        filter(year == min(historical_emissions_data$year) |
                 year == max(historical_emissions_data$year)) %>% 
        pull(value) %>% 
        round(6)
      
      #progress to net zero
      progress_percent <- ((end_values[1] - end_values[2]) / end_values[1]) * 100
      
      output$base_level <- renderInfoBox({
          infoBox(
            paste0("Base Level (", min(historical_emissions_data$year), ") :"),
            end_values[1], icon = icon("step-backward"),
            color = "yellow"
          )
        })
      
      output$current_emissions_level <- renderInfoBox({
        infoBox(
          paste0("Most Recent Year (", max(historical_emissions_data$year), ") :"),
          end_values[2], icon = icon("calendar-o"),
          color = "green"
        )
      })
      
      output$net_zero_progress <- renderInfoBox({
        infoBox(
          "Progress to Net Zero",
          paste0(round(progress_percent, 2), "%"), icon = icon("percent"),
          color = "teal"
          
        )
      })
      
      highest_emissions_cat <- historical_emissions_data %>% 
        filter(year == max(historical_emissions_data$year)) %>% 
        group_and_summarise_excluding(c("pollutant", "year", "value", "units")) %>%
        slice_max(value)
      
      output$highest_emissions_sector <- renderInfoBox({
        infoBox(
          HTML(paste0("Sector with Highest", "<br>",
                      "Emissions (", max(historical_emissions_data$year), ") :")),
          HTML(paste0(highest_emissions_cat["ccp_mapping"], "<br>",
                      round(highest_emissions_cat["value"], 6))),
          #TODO: make icon change depending on industry
          icon = icon("car"),
          color = "red"
        )
      })
      
      days_until_cop <- as.numeric(date_of_cop - Sys.Date())
      
      output$days_until_cop <- renderInfoBox({
        infoBox(
          HTML(paste0("Days until COP26", "<br>" ,"UN climate change conference")),
          days_until_cop,
          icon = icon("globe"),
          color = "teal"
        )
      })
    } else if (sector() == "Emissions") {
        
      
      # ----- emissions exploration -----
      
      # sunburst plots
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
      
      # historical emissions
      
      
      # react to plot options
      filtered_data <- eventReactive(input$update_historical_plt, ignoreNULL = FALSE, {
        historical_emissions_data %>%
          filter(year >= input$year_historic[1] & year <= input$year_historic[2]) %>%
          filter(pollutant %in% input$pollutant_historic)
      })
      
      line_plot <- eventReactive(input$update_historical_plt, ignoreNULL = FALSE, {
        filtered_data() %>% 
          group_and_summarise_including("year") %>%
          create_line_plot()
      })
      
      output$historical_emissions_plt_line <- renderPlotly(
        line_plot()
      )
      
      bar_plot <- eventReactive(input$update_historical_plt, ignoreNULL = FALSE, {
        filtered_data() %>% 
          group_and_summarise_excluding(c("pollutant", "year", "value", "units")) %>% 
          create_bar_plot()
      })
      
      output$historical_emissions_plt_bar <- renderPlotly(
        bar_plot() 
      )
      
      area_plot <- eventReactive(input$update_historical_plt, ignoreNULL = FALSE, {
        filtered_data() %>% 
          group_and_summarise_excluding(c("pollutant", "value", "units")) %>% 
          create_area_plot()
      })
      
      output$historical_emissions_plt_area <-renderPlotly(
        area_plot()
      )

    }
  })
}
