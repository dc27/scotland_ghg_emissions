ui <- dashboardPage(
  dashboardHeader(title = "Scotland Emissions - Path to Net Zero",
                  titleWidth = 500),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    # specify box heights in css
    tags$style(
      type = "text/css",
      "
      
      "
    ),
    fluidPage(
      fluidRow(
        # main ui select
        box(
          id = "data_select",
          title = "Sector",
          solidHeader = TRUE,
          status = "success",
          width = 4,
          height = "70vh",
          selectInput(
          "user_sector",
           label = "Select Sector:",
           choices = names(dfs),
           selected = "All"
          ),
          selectInput(
            "user_dataset", label = "Select Dataset:", choices = NULL
          ),
          tags$hr(),
          uiOutput("dynamic_dropdowns"),
          tags$hr(),
          radioButtons(
            "user_plot", label = "Plot Type:", choices = ""
          ),
          tags$div(style = "text-align:center;",
                   actionButton("update", "Confirm Selection")
          )
        ),
        # chart
        tabBox(
          id = "vis_box",
          width = 8,
          title = textOutput("title"),
          height = "70vh",
          tabPanel(
            "Chart",
            plotlyOutput("plot", height = "62vh")
          ),
          tabPanel(
            "Sector Targets"
          )
        )
      ),
      fluidRow(
        # TODO::
        # additional information, links
        box(
          id = "extra_info",
          title = "Information and Links",
          solidHeader = TRUE,
          status = "success",
          width = 12,
          height = "20vh"
        )
      )
    )
  )
)