source("R/filter_vars_and_join_functions.R")

server <- function(input, output, session) {
  
  create_hierarchical_plot <- function(df = selected_df(), plot_type = "Sunburst") {
    p_type <- str_to_lower(plot_type)
    
    # 0. create empty list to store dfs to be plotted side by side
    plot_dfs <- list()
    
    # 1. separate emissions and (usually carbon) sinks
    plot_dfs$emissions <- 
        df %>%
        filter(!value < 0) %>%
        group_by(id, label, parent) %>%
        summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>%
        mutate(units = "megatonnes of CO2 equivelant")

    plot_dfs$sinks <- df %>%
      filter(value < 0) %>%
      mutate(value = value * -1) %>%
      group_by(id, label, parent) %>%
      summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>%
      mutate(units = "megatonnes of CO2 equivelant")
    
      fig <- plot_ly()

      fig <- fig %>%
        add_trace(
          name = "Emissions",
          ids = plot_dfs$emissions$id,
          labels = plot_dfs$emissions$label,
          parents = plot_dfs$emissions$parent,
          values = plot_dfs$emissions$value,
          text = plot_dfs$emissions$units,
          type = p_type,
          maxdepth = 2,
          domain = list(column = 0),
          branchvalues = 'total',
          insidetextorientation = 'radial',
          text = ~units,
          textinfo='label+percent root+value',
          hoverinfo = paste("%{label}: <br>%{value}",'text')
        )
      fig <- fig %>%
        add_trace(
          name = "Sinks",
          ids = plot_dfs$sinks$id,
          labels = plot_dfs$sinks$label,
          parents = plot_dfs$sinks$parent,
          values = plot_dfs$sinks$value,
          text = plot_dfs$sinks$units,
          type = p_type,
          maxdepth = 2,
          domain = list(column = 1),
          branchvalues = 'total',
          insidetextorientation = 'radial',
          text = ~units,
          textinfo='label+percent root+value',
          hoverinfo = paste("%{label}: <br>%{value}",'text')
        )
      fig <- fig %>%
        layout(
          grid = list(columns =2, rows = 1),
          margin = list(l = 0, r = 0, b = 0, t = 0))
      
    return(fig)
  }
  
  
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
      value = c(2018)
    )
    }
  })
  
  selected <- eventReactive(input$update, {
    each_var <- map(vars(), ~ filter_var(dataset()[[.x]], input[[.x]]))
    reduce(each_var, `&`)
  })
  
  selected_df <- eventReactive(input$update, {
    dataset()[selected(), ]
  })
  
  plot <- eventReactive(input$update, {
    if (input$user_plot == "Line") {
      selected_df() %>%
        group_by(year) %>% 
        summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>% 
        ggplot() +
        aes(x = year, y = value) +
        geom_line() +
        geom_point() +
        ylim(0, NA)
    } else if (input$user_plot == "Bar") {
      selected_df() %>% 
        group_by(ccp_mapping, pollutant) %>% 
        summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>% 
        ggplot() +
        aes(x = ccp_mapping, y = value, fill = ccp_mapping) +
        geom_col(position = "stack", show.legend = FALSE)
    } else if(input$user_plot == "Sunburst") {
      create_hierarchical_plot(selected_df(), "Sunburst")
    } else if(input$user_plot == "Treemap") {
      create_hierarchical_plot(selected_df(), "Treemap")
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
  # emissions_breakdown_plots <- eventReactive(input$update, {
  #   fig <- plot_ly()
  #   
  #   fig <- fig %>%
  #     add_trace(
  #       name = "Emissions",
  #       ids = dfs()$emissions$id,
  #       labels = dfs()$emissions$label,
  #       parents = dfs()$emissions$parent,
  #       values = dfs()$emissions$value,
  #       text = dfs()$emissions$units,
  #       type = 'sunburst',
  #       maxdepth = 2,
  #       domain = list(column = 0),
  #       branchvalues = 'total',
  #       insidetextorientation = 'radial',
  #       text = ~units,
  #       textinfo='label+percent root+value',
  #       hoverinfo = paste("%{label}: <br>%{value}",'text')
  #     )
  #   fig <- fig %>%
  #     add_trace(
  #       name = "Sinks",
  #       ids = dfs()$sinks$id,
  #       labels = dfs()$sinks$label,
  #       parents = dfs()$sinks$parent,
  #       values = dfs()$sinks$value,
  #       text = dfs()$sinks$units,
  #       type = 'sunburst',
  #       maxdepth = 2,
  #       domain = list(column = 1),
  #       branchvalues = 'total',
  #       insidetextorientation = 'radial',
  #       text = ~units,
  #       textinfo='label+percent root+value',
  #       hoverinfo = paste("%{label}: <br>%{value}",'text')
  #     )
  #   fig <- fig %>%
  #     layout(
  #       grid = list(columns =2, rows = 1),
  #       margin = list(l = 0, r = 0, b = 0, t = 0))
  #   
  # })
  #   
  # output$emissions_breakdowns <- renderPlotly({
  #     emissions_breakdown_plots()
  # })
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
