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
        selectInput("col_choice", "Category Method", 
                    choices = c("National Communication Categories" = colnames(emissions_data)[1],
                                "SG Source Sector" = colnames(emissions_data)[2],
                                "CCP Mapping" = colnames(emissions_data)[3]))
      ),
      column(
        6,
        radioButtons(inline = TRUE, "plot_choice", "Plot Options",
                     choices = c("Scatter", "Area", "Line", "Sankey")),
        actionButton("update", "Update")
      )
    ),
    fluidRow(
      plotOutput("emission_graph")
    )
  )
)