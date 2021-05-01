ui <- dashboardPage(
  dashboardHeader(title = "Scotland Emissions"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$style(
      type = "text/css",
      "
      #totals_plot {height: calc(100vh - 200px) !important;}
      #emissions_breakdowns {height: calc(100vh - 200px) !important;}
      #transport_main {height: calc(100vh - 160px) !important;}
      #new_ulevs {height: calc(100vh - 250px) !important;}
      #road_traffic {height: calc(100vh - 300px) !important;}
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