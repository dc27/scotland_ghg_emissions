source("R/filter_vars_and_join_functions.R")
source("R/plot_functions.R")

server <- function(input, output, session) {
  
  sector <- reactive({
    input$user_sector
  })
  
  observeEvent(sector(), {
    updateSelectInput(
      input = "user_dataset",
      choices = names(dfs[[input$user_sector]])
      )
  })
  
  dataset <- reactive(dfs[[input$user_sector]][[input$user_dataset]]$data)
  vars <- reactive(dfs[[input$user_sector]][[input$user_dataset]]$explorable_vars)
  plot_options <- reactive(dfs[[input$user_sector]][[input$user_dataset]]$plot_options)
  
  # dynamic input options - construct dropdowns
  output$dynamic_dropdowns <- renderUI(
    map(vars(), ~ make_dropdown(dataset()[[.x]], .x))
  )
  
  observeEvent(dataset(), {
    updateRadioButtons(
      input = "user_plot",
      choices = str_to_title(plot_options())
    )
  })
  
  plot_choice <- reactive({
    input$user_plot
  })
  
  observe({
    if (plot_choice() != "Line") {
    updateSliderInput(
      input = "year",
      # cheat to set to max year
      value = 3000,
    )
    }
  })
  
  selected <- eventReactive(input$update, {
    each_var <- map(vars(), ~ filter_var(dataset()[[.x]], input[[.x]]))
    reduce(each_var, `&`)
  })
  
  selected_df <- eventReactive(input$update, {
    selected_df <- dataset()[selected(), ]
    
    # summary plots require grouping
    if (input$user_sector == "All") {
      if(input$user_plot == "Bar") {
        selected_df <- selected_df %>% 
          group_and_summarise(ccp_mapping, pollutant)
      } else if (input$user_plot == "Line") {
        selected_df <- selected_df %>% 
          group_and_summarise(year)
      }
    }
    return(selected_df)
  })
  
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

  output$plot <- renderPlotly({
    plot()
  })
  
  title_text <- eventReactive(input$update, {
    paste0("Selected: ", input$user_dataset)
  })

  output$title <- renderText(
    title_text()
  )
  
  # ----- Overview -----
  # filtered_emissions <- eventReactive(input$update,
  #                                     ignoreNULL = FALSE,
  #                                     {
  #   emissions_data %>% 
  #     filter(year == input$year_select) %>%
  #     filter(pollutant %in% c(input$gas_select)) %>% 
  #     group_by(ccp_mapping, pollutant) %>% 
  #     summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last')
  # })
  # 
  # filtered_hierarchy <- eventReactive(
  #   input$update,
  #   {
  #     hierarchical_emissions %>% 
  #       filter(year == input$year_select) %>% 
  #       filter(pollutant %in% c(input$gas_select))
  # })
  # 
  # emissions <- eventReactive(
  #   input$update, {
  #     filtered_hierarchy() %>%
  #     filter(!value < 0) %>%
  #     group_by(id, label, parent) %>%
  #     summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>%
  #     mutate(units = "megatonnes of CO2 equivelant")
  #   })
  # 
  # sinks <- eventReactive(
  #   input$update, {
  #     filtered_hierarchy() %>%
  #   filter(value < 0) %>%
  #   mutate(value = value * -1) %>%
  #   group_by(id, label, parent) %>%
  #   summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>%
  #   mutate(units = "megatonnes of CO2 equivelant")
  #   })
  # 
  # dfs <- eventReactive(
  #   input$update, {
  #     list("emissions" = emissions(),
  #             "sinks" = sinks())
  #   })
  # 
  # emission_totals_plot <- eventReactive(
  #   input$update,
  #   ignoreNULL = FALSE,
  #   {
  #     p <- filtered_emissions() %>% 
  #     ggplot() +
  #       aes(x = factor(ccp_mapping, levels = rev(levels(factor(ccp_mapping)))),
  #                   y = value, fill = ccp_mapping,
  #                   text = paste0('</br> Sector: ', ccp_mapping,
  #                                 '</br> Emissions: ', value)) +
  #       geom_col() +
  #       theme_bw() +
  #       theme(legend.position = "none") +
  #       scale_fill_viridis_d() +
  #       labs(x = "Sector",
  #            y = paste0("Emissions (", emissions_data$units[1], ")")) +
  #       coord_flip()
  #     
  #     if (input$facet_select == "multiple") {
  #       p <- p +
  #         facet_wrap(~pollutant)
  #     }
  #     
  #     return(p)
  #   })
  # 
  # 
  # output$totals_plot <- renderPlotly({
  #   ggplotly(
  #     emission_totals_plot(),
  #     tooltip = 'text'
  #   )
  # })
  # 
  # 
  # # ----- Transport -----
  # 
  # filtered_transport <- eventReactive(input$update_transport, {
  #   transport_hierarchy %>% 
  #   filter(year == input$year_transport) %>% 
  #   group_by(id, label, parent) %>% 
  #   summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>%
  #   mutate(units = "megatonnes of CO2 equivelant") %>% 
  #   data.frame(stringsAsFactors = FALSE)
  #   
  # })
  # 
  # transport_summary <- eventReactive(input$update_transport, {
  #   filtered_transport() %>% 
  #     plot_ly(
  #       ids = ~id,
  #       labels = ~label,
  #       parents = ~parent,
  #       values = ~value,
  #       type = "sunburst",
  #       branchvalues = "total",
  #       insidetextorientation = 'radial',
  #       maxdepth = 3,
  #       text =  ~units,
  #       textinfo = 'label+percent root+value+text'
  #     )
  # })
  # 
  # output$transport_main <- renderPlotly({
  #   transport_summary()
  # })
  # 
  # filtered_traffic_data <- eventReactive(input$update_transport, {
  #   road_traffic %>% 
  #     filter(vehicle_type == input$vehicle_type)
  # })
  # 
  # output$road_traffic <- renderPlot({
  #   filtered_traffic_data() %>%
  #     ggplot() +
  #     aes(x = year, y = vehicle_kilometers_millions, group = road_type,
  #         colour = road_type, legendShow = FALSE) +
  #     geom_point(size = 3) +
  #     geom_line(size = 1.2) +
  #     scale_x_continuous(breaks = seq(2010,2020,2)) +
  #     theme_bw()
  # })
  # 
  # filtered_ulev_data <- eventReactive(input$update_transport, {
  #   new_ulevs %>% 
  #     filter(body_type == input$body_type)
  # })
  # 
  # output$new_ulevs <- renderPlot({
  #   filtered_ulev_data() %>% 
  #   ggplot() +
  #     aes(x = year, y = n_ulevs_registered/n_registered) +
  #     geom_point(size = 3) +
  #     geom_line(size = 1.5) +
  #     scale_x_continuous(breaks = seq(2010,2020,2)) +
  #     scale_y_continuous(labels = scales::percent) +
  #     labs(x = "Year",
  #          y = "% Newly registered vehicles are ULEV",
  #          title = "% Newly Registered Vehicles are ULEV by Body Type - Scotland") +
  #     theme_bw()
  # })
  
}
