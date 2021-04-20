server <- function(input, output, session) {
  filtered_emissions <- eventReactive(input$update,
                                      ignoreNULL = FALSE,
                                      {
    emissions_data %>% 
      filter(year == input$year_select) %>%
      filter(pollutant %in% c(input$gas_select))
  })
  
  
  output$emissions_breakdown <- renderPlotly({
    ggplotly(
      filtered_emissions() %>% 
        ggplot() +
        aes(x = factor(ccp_mapping, levels = rev(levels(factor(ccp_mapping)))),
            y = value, fill = source_name,
            text = paste0('</br> Sector: ', ccp_mapping,
                          '</br> Emissions: ', value,
                          '</br> Source Name: ', source_name)) +
        geom_col(position = "stack") +
        theme_bw() +
        facet_wrap(~pollutant) +
        theme(legend.position = "none") +
        labs(x = "Sector",
             y = paste0("Emissions (", emissions_data$units[1], ")")) +
        coord_flip(),
      tooltip = 'text'
    )
    
  })
}
