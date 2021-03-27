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
    box(
      width = 9,
      leafletOutput("scotland_map")
    ),
    column(
      width = 3
    )
  )
)
