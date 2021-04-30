server <- function(input, output, session) {
  filtered_emissions <- eventReactive(input$update,
                                      ignoreNULL = FALSE,
                                      {
    emissions_data %>% 
      filter(year == input$year_select) %>%
      filter(pollutant %in% c(input$gas_select)) %>% 
      group_by(ccp_mapping, pollutant) %>% 
      summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last')
  })
  
  filtered_hierarchy <- eventReactive(
    input$update,
    {
      hierarchical_emissions %>% 
        filter(year == input$year_select) %>% 
        filter(pollutant %in% c(input$gas_select))
  })
  
  emissions <- eventReactive(
    input$update, {
      filtered_hierarchy() %>%
      filter(!value < 0) %>%
      group_by(id, label, parent) %>%
      summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>%
      mutate(units = "megatonnes of CO2 equivelant")
    })

  sinks <- eventReactive(
    input$update, {
      filtered_hierarchy() %>%
    filter(value < 0) %>%
    mutate(value = value * -1) %>%
    group_by(id, label, parent) %>%
    summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>%
    mutate(units = "megatonnes of CO2 equivelant")
    })

  dfs <- eventReactive(
    input$update, {
      list("emissions" = emissions(),
              "sinks" = sinks())
    })
  
  emission_totals_plot <- eventReactive(
    input$update,
    ignoreNULL = FALSE,
    {
      p <- filtered_emissions() %>% 
      ggplot() +
        aes(x = factor(ccp_mapping, levels = rev(levels(factor(ccp_mapping)))),
                    y = value, fill = ccp_mapping,
                    text = paste0('</br> Sector: ', ccp_mapping,
                                  '</br> Emissions: ', value)) +
        geom_col() +
        theme_bw() +
        theme(legend.position = "none") +
        scale_fill_viridis_d() +
        labs(x = "Sector",
             y = paste0("Emissions (", emissions_data$units[1], ")")) +
        coord_flip()
      
      if (input$facet_select == "multiple") {
        p <- p +
          facet_wrap(~pollutant)
      }
      
      return(p)
    })
  
  
  output$totals_plot <- renderPlotly({
    ggplotly(
      emission_totals_plot(),
      tooltip = 'text'
    )
  })
  
  emissions_breakdown_plots <- eventReactive(input$update, {
    fig <- plot_ly()
    
    fig <- fig %>%
      add_trace(
        name = "Emissions",
        ids = dfs()$emissions$id,
        labels = dfs()$emissions$label,
        parents = dfs()$emissions$parent,
        values = dfs()$emissions$value,
        text = dfs()$emissions$units,
        type = 'sunburst',
        maxdepth = 2,
        domain = list(column = 0),
        branchvalues = 'total',
        insidetextorientation = 'radial',
        marker=list(colorscale='Viridis'),
        text = ~units,
        textinfo='label+percent root+value',
        hoverinfo = paste("%{label}: <br>%{value}",'text')
      )
    fig <- fig %>%
      add_trace(
        name = "Sinks",
        ids = dfs()$sinks$id,
        labels = dfs()$sinks$label,
        parents = dfs()$sinks$parent,
        values = dfs()$sinks$value,
        text = dfs()$sinks$units,
        type = 'sunburst',
        maxdepth = 2,
        domain = list(column = 1),
        branchvalues = 'total',
        insidetextorientation = 'radial',
        marker=list(colorscale='Viridis'),
        text = ~units,
        textinfo='label+percent root+value',
        hoverinfo = paste("%{label}: <br>%{value}",'text')
      )
    fig <- fig %>%
      layout(
        grid = list(columns =2, rows = 1),
        margin = list(l = 0, r = 0, b = 0, t = 0))
    
  })
    
  
  
  output$emissions_breakdowns <- renderPlotly({
      emissions_breakdown_plots()
  })
}
