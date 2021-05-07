ui <- dashboardPage(
  dashboardHeader(title = "Scotland Emissions - Path to Net Zero",
                  titleWidth = 500),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    # specify box heights in css
    tags$style(
      type = "text/css",
      "
      #data_select {height: calc(100vh - 35vh) !important;}
      #plot_box {height: calc(100vh - 35vh) !important;}
      div.box.box-solid.box-primary {text-align: right;}
      #plot {height: 100% !important;}
      #extra_info {height: 15vh !important;}
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
        box(
          id = "plot_box",
          solidHeader = TRUE,
          status = "primary",
          title = textOutput("title"),
          width = 8,
          plotOutput("plot")
        )
      ),
      fluidRow(
        box(
          id = "extra_info",
          title = "Information and Links",
          solidHeader = TRUE,
          status = "success",
          width = 12,
        )
      )
    )
  )
)