ui <- tagList(
  dashboardPage(
    dashboardHeader(
      title = "Scotland Emissions - Path to Net Zero",
      titleWidth = 500
    ),
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
            .no_padding_col {
            padding: 0;
            }
            .bttn-simple {
            width:100%;
            height:10vh;
            border-radius: 0;
            }
            #goto_emissions_explorer {
            margin-bottom: 1vh;
            height:20vh;
            width:100%;
            background-color: white;
            color:black;
            font-size: 20px;
            font-family: inherit;
            padding: 5px 12px;
            }
            .bttn-bordered {
            background-color: white;
            width:100%;
            height:10vh;
            }
            .box-solid.bg-blue {
            background-color: lightblue;
            margin:1vh;
            text-align:center;
            }
            h2{
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
            .panel.panel-default {
            z-index: 1000;
            }
            .box-warning {
            margin-top: 1vh;
            box-shadow: none;
            }
            h3.box-title {
            margin: 0.5vh;
            }
            #emissions_plot
            {height: calc(100vh - 23vh) !important;}
            #sinks_plot
            {height: calc(100vh - 23vh) !important;}
            .plotly.html-widget
            {height: calc(100vh - 30vh) !important;}
            footer {
            background-color: grey
            margin-bottom:0;
            }
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
              class = "no_padding_col",
              box(
                title = "",
                width = 12,
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
              tags$button(
                id = "goto_emissions_explorer",
                class = "btn action-button",
                tags$img(src = myImgResources, height = "100%"),"Emissions Explorer"
                
              ),
             tags$br(),
             column(
               6,
               class = "no_padding_col",
               actionBttn(
                 style = "simple", color = "success",
                 icon = icon("tractor"),
                 inputId = 'goto_agriculture',
                 label = 'Agriculture'
               ),
               actionBttn(
                 style = "simple", color = "success",
                 inputId = 'goto_transport',
                 icon = icon("car"),
                 label = 'Transport'
               ),
               actionBttn(
                 style = "simple", color = "success",
                 inputId = 'goto_industry',
                 icon = icon("industry"),
                 label = 'Industry'
               ),
               actionBttn(
                 style = "simple", color = "success",
                 inputId = 'goto_landuse',
                 icon = icon("sync"),
                 label = 'Land Use'
               )
             ),
             column(
               6,
               class = "no_padding_col",
               actionBttn(
                 style = "simple", color = "success",
                 inputId = 'goto_electricity',
                 icon = icon("bolt"),
                 label = 'Electricity Generation'
               ),
               actionBttn(
                 style = "simple", color = "success",
                 inputId = 'goto_services',
                 icon = icon("asterisk"),
                 label = 'Services'
               ),
               actionBttn(
                 style = "simple", color = "success",
                 inputId = 'goto_waste',
                 icon = icon("trash"),
                 label = 'Waste'
               ),
               actionBttn(
                 style = "simple", color = "success",
                 inputId = 'goto_residential',
                 icon = icon("building"),
                 label = 'Residential'
               )
             )
             # actionBttn(
             #   style = "simple", color = "success",
             #   inputId = 'goto_targets',
             #   label = 'Targets Tracker'
             #  ),
            )
          )
        ),
        # ------ Emissions Exploration Page -----
        tabPanel(
          title = "Emissions Explorer", value = "emissions", 
          fluidRow(
            column(
              2,
              class = "no_padding_col",
              actionBttn(
                style = "bordered", color = "success", icon = icon("home"),
                inputId = 'return_home_1',
                label = 'Home'
              )
            ),
            column(
              10,
              tags$div(
                class = "header_box",
                box(
                  title = "",
                  width = 12,
                  height = "10vh",
                  background = "light-blue",
                  tags$div(
                    class = "verti-hori-center",
                    tags$h2(
                      "Emissions Hub - Path to Net Zero"
                    )
                  )
                )
              )
            )
          ),
          navlistPanel(
            widths = c(2,10),
            "Emissions Hub",
            tabPanel(
              "Sector Breakdowns",
              tabBox(
                width = 12,
                tabPanel(
                  "Emissions",
                  plotlyOutput("emissions_plot")
                ),
                tabPanel(
                  "Sinks",
                  plotlyOutput("sinks_plot")
                )
              )
            ),
            tabPanel(
              "Historical Emissions",
              absolutePanel(
                id = "controls", fixed = TRUE, class = "panel panel-default",
                draggable = TRUE, top = 60, left = "auto", right = 20,
                bottom = "auto",
                width = "20vw", padding = "1vh",
                
                # plot options are the same for all historical plots - year/
                # pollutant input and update button
                box(
                  title = "Plot Options",
                  status = "warning",
                  width = 12,
                  collapsible = TRUE,
                  sliderInput(
                    width = "100%", "year_historic", "Year(s) :",min = 1990, max = 2018,
                    value = c(1990, 2018)),
                  pickerInput("pollutant_historic",
                              "Pollutant(s) :", 
                              # select all as default
                              choices = sort(unique(dfs$All$`Historic Emissions`$data$pollutant)),
                              selected = sort(unique(dfs$All$`Historic Emissions`$data$pollutant)),
                              options = list(`actions-box` = TRUE),
                              multiple = TRUE
                  ),
                  actionButton("update_historical_plt", "Update Plot")
                  
                )
              ),
              tabBox(
                width = 12,
                # plot options
                tabPanel(
                  "Line",
                  plotlyOutput("historical_emissions_plt_line")
                ),
                tabPanel(
                  "Bar",
                  plotlyOutput("historical_emissions_plt_bar")
                ),
                tabPanel(
                  "Area",
                  plotlyOutput("historical_emissions_plt_area")
                )
              )
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
          actionButton('return_home_3', 'Home'),
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
        )
      )
    )
  ),
  # footer - visible on all pages
  tags$footer("STA logo", align = "left", style = " 
                bottom:0;
                width:100%;
                height:25vh;
                color: white;
                padding: 10px;
                background-color: grey;
                z-index: 1000;")
)
