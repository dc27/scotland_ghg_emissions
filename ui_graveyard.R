ui <- dashboardPage(
  dashboardHeader(title = "Scotland Emissions"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$style(
      type = "text/css",
      "
      #totals_plot {height: calc(100vh - 200px) !important;}
      #emissions_breakdowns {height: calc(100vh - 200px) !important;}
      #transport_main {height: calc(100vh - 50vh) !important;}
      #new_ulevs {height: calc(100vh - 50vh) !important;}
      #road_traffic {height: calc(100vh - 50vh) !important;}
      "
    ),
    tabsetPanel(
      tabPanel(
        "Overview",
        fluidRow(
          column(
            3,
            selectInput("year_select", "Year: ", 
                        choices = years,
                        selected = "2018"),
            pickerInput("gas_select", "Pollutant(s): ", 
                        choices = pollutants,
                        selected = "CO2",
                        options = list(`actions-box` = TRUE),
                        multiple = TRUE),
            radioButtons("facet_select", "Faceting: ",
                         choices = c("single", "multiple"),
                         selected = "single"),
            tags$br(),
            actionButton("update", "Update")
          ),
          column(
            9,
            tabBox(
              width = 12,
              tabPanel(
                "Totals",
                plotlyOutput("totals_plot")
              ),
              tabPanel(
                "Breakdown",
                plotlyOutput("emissions_breakdowns")
              ),
              tabPanel(
                "Temporal"
              )
            )
          )
        )
      ),
      tabPanel(
        "Transport",
        fluidRow(
          column(
            3,
            selectInput("year_transport", "Year: ",
                        choices = years,
                        selected = "2018")
          ),
          column(
            3,
            tags$br(),
            actionButton("update_transport", "Update")
          ),
          column(
            3,
            selectInput("body_type", "Body Type: ",
                        choices = body_types,
                        selected = "Cars")
          ),
          column(
            3,
            selectInput("vehicle_type", "Vehicle Type: ",
                        choices = vehicle_types,
                        selected = "Car")
          )
        ),
        fluidRow(
          column(
            6,
            box(
              width = 12,
              "Summary",
              plotlyOutput("transport_main")
            )
          ),
          column(
            6,
            tabBox(
              width = 12,
              tabPanel(
                "Newly Registered ULEVs",
                plotOutput("new_ulevs")
              ),
              tabPanel(
                "Licensed Vehicles",
                plotOutput("licensend_vehicles")
              ),
              tabPanel(
                "Road Transport",
                plotOutput("road_traffic")
              )
            )
          )
        )
      )
    )
  )
)

# server graveyard

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
