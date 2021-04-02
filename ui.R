ui <- dashboardPage(
  dashboardHeader(title = "Scotland Emissions"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$style(
      type = "text/css",
      "
      #scotland_map {height: calc(100vh - 160px) !important;}
      "
    ),
    tabsetPanel(
      tabPanel(
        "CO2 Emissions",
        fluidRow(
          box(
            width = 9,
            leafletOutput("scotland_map")
          ),
          column(
            width = 3,
            pickerInput("subsector",
                        "Subsector(s):",
                        choices = subsectors,
                        options = list(`actions-box` = TRUE),multiple = T),
            tags$hr(),
            sliderInput("year",
                        "Year",
                        value = 2018,
                        max = max(years), min = min(years),
                        sep = "",
                        ticks = TRUE
            ),
            checkboxInput("per_capita", "per capita", FALSE),
            checkboxInput("per_sq_km", "per square kilometer", FALSE),
            checkboxInput("legend", "Show legend", TRUE),
            tags$div(style = "text-align:center;",
                     actionButton("update", "Update"))
          )
        )
      ),
      tabPanel(
        "Transport"
      )
    )
  )
)
