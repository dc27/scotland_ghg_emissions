ui <- dashboardPage(
  dashboardHeader(title = "Scotland Emissions"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    selectInput("col_choice", "Category Method", colnames(emissions_data)[1:3]),
    uiOutput("dropdowns"),
    textOutput("test_text")
  )
)