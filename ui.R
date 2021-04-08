ui <- dashboardPage(
  dashboardHeader(title = "Scotland Emissions"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$style(
      type = "text/css",
      "
      #emission_graph {height: calc(100vh - 160px) !important;}
      "
    ),
    fluidRow(
      column(
        6,
        selectInput("col_choice", "Category Method", colnames(emissions_data)[1:3])
      ),
      column(
        6,
        uiOutput("dropdowns")
      )
    ),
    fluidRow(
      plotOutput("emission_graph")
    )
  )
)