source("global.R", local = TRUE)

ui <- dashboardPage(skin = "black",
                    
                    # Header ----
                    header <- dashboardHeader(title = "Microbiome analysis",
                                              tags$li(actionBttn(
                                                "getting_started_help",
                                                label = "Getting started",
                                                style = "bordered",
                                                color = "primary",
                                                size = "sm"
                                              ), style = "width: 140px;
                                              padding-right:0px;
                                              padding-top:10px;
                                              height:20px;
                                              margin-right:0px;
                                              font-size: 20px;
                                              ",
                                              class = "dropdown"),
                                              tags$li(a(href = "https://www.organisation.com",
                                                        img(src = "university-of-bath-logo.png",
                                                            title = "organisation",
                                                            height = "40px"),
                                                        style = "padding-top:5px;
                                                        padding-bottom:5px;
                                                        padding-left:10px !important;
                                                        margin-left:0px !important;"),
                                                      class = "dropdown")
                    ),
                    # Sidebar ----
                    sidebar <- dashboardSidebar(width = 240,
                                                shinyjs::useShinyjs(),
                                                tags$head(
                                                  tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
                                                ),
                                                sidebarMenu(id = "main_menu", 
                                                            style = "font-size:16px",
                                                            ## Data ----
                                                            menuItem("Data",
                                                                     tabName = "data",
                                                                     icon = icon("list",
                                                                                 lib = "glyphicon"
                                                                     )
                                                            ),
                                                            conditionalPanel(condition = "input.main_menu == 'data'",
                                                            ),
                                                            ## Graphs ----
                                                            menuItem("Graphs",
                                                                     tabName = "graphs",
                                                                     icon = icon("stats",
                                                                                 lib = "glyphicon"
                                                                     )
                                                            ),
                                                            add_busy_bar(color = "#0096FF", timeout = 400, height = "4px"),
                                                            conditionalPanel(condition = "input.main_menu == 'graphs'",
                                                            ),
                                                            ## About ----
                                                            menuItem("About",
                                                                     tabName = "about",
                                                                     icon = icon("info-sign",
                                                                                 lib = "glyphicon"
                                                                     )
                                                            ),
                                                            conditionalPanel(condition = "input.main_menu == 'about'"         
                                                            )
                                                )
                    ),
                    # Body ----
                    body <- dashboardBody(style = "padding:0px;",
                                          tabItems(
                                            ### Data ----
                                            tabItem(tabName = "data",
                                                    fluidRow(style = "padding: 15px;", 
                                                             column(width = 12,
                                                                    style="padding:0px",
                                                                    tabBox(width = 12,
                                                                           tabPanel("Live data",
                                                                                    tags$div(
                                                                                      textOutput("output.live_data.text"),
                                                                                      style = "padding-bottom: 10px; color: red;"
                                                                                    ),
                                                                                    tags$div(
                                                                                      dataTableOutput(outputId = "output.live_data"),
                                                                                      style = "width: 100%; overflow-x: auto;"
                                                                                    )
                                                                           ),
                                                                           tabPanel("Upload data",
                                                                                    tags$div(
                                                                                    actionBttn(inputId = "user.upload.single",
                                                                                               label = "Upload file",
                                                                                               icon = icon("cloud-upload",
                                                                                                           lib = "glyphicon"),
                                                                                               size = "sm"
                                                                                    ),
                                                                                    style = "margin-right:5px; display: inline-block;"
                                                                                    ),
                                                                                    tags$div(
                                                                                      actionBttn(inputId = "user.upload.zip",
                                                                                                 label = "Upload ZIP",
                                                                                                 icon = icon("cloud-upload",
                                                                                                             lib = "glyphicon"),
                                                                                                 size = "sm"
                                                                                      ),
                                                                                      style = "display: inline-block;"
                                                                                    ),
                                                                                    tags$div(
                                                                                      textOutput("output.upload.help"),
                                                                                      style = "padding-bottom: 10px; color: green; padding-top: 10px;"
                                                                                    ),
                                                                                    tags$div(
                                                                                      textOutput("output.example_table.text"),
                                                                                      style = "padding-bottom: 10px; color: red; padding-top: 10px;"
                                                                                    ),
                                                                                    tags$div(
                                                                                      dataTableOutput(outputId = "output.example_table"),
                                                                                      style = "width: 100%; overflow-x: auto;"
                                                                                    )
                                                                           ),
                                                                    )
                                                             )
                                                    )    
                                                    
                                            ),
                                            ## Graphs ----
                                            tabItem(tabName = "graphs",
                                                    fluidRow(style = "padding: 15px;", 
                                                             column(width = 12,
                                                                    style="padding:0px;",
                                                                    tabBox(width = 12,
                                                                           tabPanel("Controls",
                                                                                    tags$div(
                                                                                      downloadBttn("download.controls",
                                                                                                   "Download",
                                                                                                   size = "xs",
                                                                                      ),
                                                                                      style = "padding-bottom:10px"
                                                                                    ),
                                                                                    plotOutput(outputId = "output.controls", width = "50%", height = "55vh"),
                                                                           ),
                                                                           tabPanel("Barplots",
                                                                                    fluidRow(style = "padding: 15px;", 
                                                                                             column(width = 12,
                                                                                                    style="padding:0px",
                                                                                                    tabBox(width = 12,
                                                                                                           tabPanel("Simple",
                                                                                                                    tags$div(
                                                                                                                      downloadBttn("download.barplot.simple",
                                                                                                                                   "Download",
                                                                                                                                   size = "xs",
                                                                                                                      ),
                                                                                                                      style = "padding-bottom:10px"
                                                                                                                    ),
                                                                                                                    plotOutput(outputId = "output.barplot.simple", width = "50%")
                                                                                                           ),
                                                                                                           tabPanel("Stacked",
                                                                                                                    tags$div(
                                                                                                                      downloadBttn("download.barplot.stacked",
                                                                                                                                   "Download",
                                                                                                                                   size = "xs",
                                                                                                                      ),
                                                                                                                      style = "padding-bottom:10px"
                                                                                                                    ),
                                                                                                                    plotOutput(outputId = "output.barplot.stacked", width = "50%")
                                                                                                           )
                                                                                                    )
                                                                                             )
                                                                                    )
                                                                                    
                                                                           ),
                                                                           tabPanel("Density",
                                                                                    tags$div(
                                                                                      downloadBttn("download.density",
                                                                                                   "Download",
                                                                                                   size = "xs",
                                                                                      ),
                                                                                      style = "padding-bottom:10px"
                                                                                    ),
                                                                                    plotOutput(outputId = "output.density", width = "50%")
                                                                           ),
                                                                           tabPanel("Heatmap",
                                                                                    fluidRow(style = "padding: 15px;", 
                                                                                             column(width = 12,
                                                                                                    style="padding:0px",
                                                                                                    tabBox(width = 12,
                                                                                                           tabPanel("Simple",
                                                                                                                    tags$div(
                                                                                                                      downloadBttn("download.heatmap.simple",
                                                                                                                                   "Download",
                                                                                                                                   size = "xs",
                                                                                                                      ),
                                                                                                                      style = "padding-bottom:10px"
                                                                                                                    ),
                                                                                                                    plotOutput(outputId = "output.heatmap.simple", width = "50%")
                                                                                                           ),
                                                                                                           tabPanel("Clustered",
                                                                                                                    tags$div(
                                                                                                                      downloadBttn("download.heatmap.clustered",
                                                                                                                                   "Download",
                                                                                                                                   size = "xs",
                                                                                                                      ),
                                                                                                                      style = "padding-bottom:10px"
                                                                                                                    ),
                                                                                                                    plotOutput(outputId = "output.heatmap.clustered", width = "50%")
                                                                                                           )
                                                                                                    )
                                                                                             )
                                                                                    )
                                                                           ),
                                                                           tabPanel("Treemap",
                                                                                    tags$div(
                                                                                      downloadBttn("download.treemap",
                                                                                                   "Download",
                                                                                                   size = "xs",
                                                                                      ),
                                                                                      style = "padding-bottom:10px"
                                                                                    ),
                                                                                    plotOutput(outputId = "output.treemap", width = "50%")
                                                                           ),
                                                                           tabPanel("PCoA",
                                                                                    tags$div(
                                                                                      downloadBttn("download.pcoa",
                                                                                                   "Download",
                                                                                                   size = "xs",
                                                                                      ),
                                                                                      style = "padding-bottom:10px"
                                                                                    ),
                                                                                    plotOutput(outputId = "output.pcoa", width = "50%")
                                                                           ),
                                                                           tabPanel("Network",
                                                                                    tags$div(
                                                                                      downloadBttn("download.network",
                                                                                                   "Download",
                                                                                                   size = "xs",
                                                                                      ),
                                                                                      style = "padding-bottom:10px"
                                                                                    ),
                                                                                    plotOutput(outputId = "output.network", width = "50%")
                                                                           ) 
                                                                    )
                                                             )
                                                    )
                                            ),
                                            ## About ----
                                            tabItem(tabName = "about",
                                                    fluidRow(style = "padding: 15px;", 
                                                             column(width = 12,
                                                                    style="padding:0px",
                                                                    tabBox(width = 12,
                                                                           tabPanel("User info",
                                                                                    includeMarkdown("www/USERINFO.md")
                                                                           ),
                                                                           tabPanel("Dev info",
                                                                                    includeMarkdown("README.md"
                                                                                    )
                                                                           )
                                                                    )
                                                             )
                                                             
                                                             
                                                             
                                                    )
                                            )
                                          )
                    ),
                    
                    dashboardPage(
                      header = header,
                      sidebar = sidebar,
                      body = body,
                    )
)
