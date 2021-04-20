ui <- dashboardPage(
  dashboardHeader(title = "Scotland Emissions"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$style(
      type = "text/css",
      "
      #emissions_breakdown {height: calc(100vh - 160px) !important;}
      "
    ),
    fluidRow(
      column(
        3,
        selectInput("year_select", "Year: ", 
                    choices = years,
                    selected = "2018"),
        selectInput("gas_select", "Pollutant(s): ", 
                    choices = pollutants,
                    selected = "CO2"),
        tags$br(),
        actionButton("update", "Update")
      ),
      column(
        9,
        plotlyOutput("emissions_breakdown")
      )
    )
  )
)