ui <- dashboardPage(
  dashboardHeader(title = "Scotland Emissions - Path to Net Zero",
                  titleWidth = 500),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    # call shinyjs
    useShinyjs(),
    # specify box heights in css
    tagList(
      # ----- css -----
      # TODO:: write separate css file
      tags$head(
        tags$style(
          type = 'text/css',
          '
          header.main-header{
          display:none;
          }
          .navbar{
          display:none;
          }
          .bttn-material-flat {
          width:100%;
          height:10vh;
          margin:1vh;
          }
          .bttn-bordered {
          width:100%;
          height:10vh;
          }
          .box-solid.bg-blue {
          background-color: lightblue;
          margin:1vh;
          }
          h1{
          text-align: center;
          }
          .verti-hori-center {
            margin: 0;
            position: absolute;
            top: 50%;
            left: 50%;
            -ms-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
          }
          .box-header {
            height:0;
            padding:0;
          }
          .info-box{
          height:14vh;
          margin:1vh;
          }
          .info-box-icon{
          height:14vh;
          width:14vh;
          }
          .info-box-content{
          text-align:right;
          }
          #emissions_plot
          {height: calc(100vh - 160px) !important;}
          '
        )
      )
    ),
    navbarPage(
      'Test App', collapsible = TRUE, id = "inTabset",
      # ----- Home Page -----
      tabPanel(
        title = "Home", value = "home",
        fluidRow(
          column(
            12,
            box(
              title = "",
              width = "100%",
              height = "20vh",
              background = "light-blue",
              tags$div(
                class = "verti-hori-center",
                tags$h1(
                  "Greenhouse Gas Emissions in Scotland - Path to Net Zero"
                )
              )
            )
          )
        ),
        fluidRow(
          column(
            4,
            id = "nav",
            actionBttn(
              style = "material-flat", color = "success", 
              inputId = 'goto_emissions_explorer',
              label = 'Emissions Explorer'
            ),
            tags$br(),
            actionBttn(
              style = "material-flat", color = "success",
              inputId = 'goto_targets_explorer',
              label = 'Target Tracker'
            ),
           tags$br(),
           actionBttn(
             style = "material-flat", color = "success",
             inputId = 'goto_choices_explorer',
             label = 'Big Emissions'
            )
          )
        )
      ),
      # ------ Emissions Exploration Page -----
      tabPanel(
        title = "Emissions Explorer", value = "emissions", 
        actionButton('return_home_1', 'Home'),
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
            # updates based on user input
            radioButtons(
              "user_plot", label = "Plot Type:", choices = ""
            ),
            checkboxInput("p_new_ulevs", "View Percentage of New Regs are ULEV"),
            tags$div(
              style = "text-align:center;",
              actionButton("update", "Confirm Selection")
            )
          ),
          # chart
          box(
            id = "vis_box",
            width = 8,
            title = textOutput("title"),
            height = "70vh",
            tabPanel(
              "Chart",
              plotlyOutput("plot", height = "62vh")
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
      ),
      # ----- Scottish Government Targets Exploration Page -----
      tabPanel(
        title = "Scottish Government Targets and Progress",
        value = "targets", 
        actionButton('return_home_2', 'Home')
      ),
      # ------ Impact of green choices page ----- 
      tabPanel(
        title = "Impact of Green Choices",
        value = "choices",
        fluidRow(
          column(
            2,
            actionBttn(
              style = "bordered", color = "success", icon = icon("home"),
              inputId = 'return_home_3',
              label = 'Home'
            )
          ),
          column(
            10,
            tags$div(
              class = "header_box",
              box(
                title = "",
                width = "100%",
                height = "10vh",
                background = "light-blue",
                tags$h2("Greenhouse Gas Emissions in Scotland - Path to Net Zero")
              )
            )
          )
        ),
        navlistPanel(
          widths = c(3,9),
          "Emissions Hub",
          tabPanel(
            "Sector Breakdowns",
            plotlyOutput("emissions_plot")
          ),
          tabPanel(
            "Historical Emissions"
          )
        )
      )
    )
  )
)