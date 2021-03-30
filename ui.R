ui <- dashboardPage(
  dashboardHeader(title = "Scotland CO2 Emissions"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$style(
      type = "text/css",
      "
      #scotland_map {height: calc(100vh - 160px) !important;}
      "
    ),
    fluidRow(
      box(
        width = 9,
        leafletOutput("scotland_map"),
        absolutePanel(
          bottom = 0,
          right = 20,
          left = 20,
          tags$style(
            ".irs-bar {",
            "  border-color: transparent;",
            "  background-color: transparent;",
            "}",
            ".irs-bar-edge {",
            "  border-color: transparent;",
            "  background-color: transparent;",
            "}"
          ),
          sliderInput("year",
                      "Select year",
                      value = 2018,
                      max = max(years), min = min(years),
                      sep = "",
                      ticks = TRUE
          )
        )
      ),
      column(
        width = 3,
        pickerInput("subsector",
                    "Subsector",
                    choices = subsectors,
                    options = list(`actions-box` = TRUE),multiple = T),
        tags$hr(),
        checkboxInput("legend", "Show legend", TRUE),
        tags$div(style = "text-align:center;",
                 actionButton("update", "Update"))
      )
    )
  )
)
