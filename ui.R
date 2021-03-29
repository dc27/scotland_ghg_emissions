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
      column(
        width = 3,
        pickerInput("indus_commercial",sectors[[1]], choices=subsectors[[sectors[[1]]]], options = list(`actions-box` = TRUE),multiple = T),
      ),
      column(
        width = 3,
        pickerInput("domestic",sectors[[2]], choices=subsectors[[sectors[[2]]]], options = list(`actions-box` = TRUE),multiple = T),
      ),
      column(
        width = 3,
        pickerInput("transport",sectors[[3]], choices=subsectors[[sectors[[3]]]], options = list(`actions-box` = TRUE),multiple = T),
      ),
      column(
        width = 3,
        pickerInput("LULUCF",sectors[[4]], choices=subsectors[[sectors[[4]]]], options = list(`actions-box` = TRUE),multiple = T),
      )
    ),
    fluidRow(
      box(
        width = 9,
        leafletOutput("scotland_map")
      ),
      tags$hr(),
      uiOutput("dropdowns"),
      checkboxInput("legend", "Show legend", TRUE),
      tags$div(style = "text-align:center;",
               actionButton("update", "Update"))
    )
  )
)
