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
                                                            ## About ----
                                                            menuItem("About",
                                                                     tabName = "about",
                                                                     icon = icon("info-sign",
                                                                                 lib = "glyphicon"
                                                                     )
                                                            ),
                                                            conditionalPanel(condition = "input.main_menu == 'about'"         
                                                            ),
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
                                                            )
                                                )
                    ),
                    # Body ----
                    body <- dashboardBody(style = "padding:0px;",
                                          tabItems(
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
                                            ),
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
                                                                           tabPanel("User data",
                                                                                    tags$div(
                                                                                      textOutput("output.example_table.text"),
                                                                                      style = "padding-bottom: 10px; color: red;"
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
                                                                    style="padding:0px",
                                                                    tabBox(width = 12,
                                                                           tabPanel("Controls",
                                                                                    tags$div(
                                                                                      downloadBttn("download.controls",
                                                                                                   "Download",
                                                                                                   size = "xs",
                                                                                      ),
                                                                                      style = "padding-bottom:10px"
                                                                                    ),
                                                                                    plotOutput(outputId = "output.controls", width = "50%")
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
                                                                                                                    selectizeInput(inputId = "input.barplot.simple.tax",
                                                                                                                                   label = "Choose taxonomic level",
                                                                                                                                   choices = NULL),
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
                                                                                                                    selectizeInput(inputId = "input.barplot.stacked.tax",
                                                                                                                                   label = "Choose taxonomic level",
                                                                                                                                   choices = NULL),
                                                                                                                    plotOutput(outputId = "output.barplot.stacked", width = "50%")
                                                                                                           ),
                                                                                                           tabPanel("Horizontal",
                                                                                                                    tags$div(
                                                                                                                      downloadBttn("download.barplot.horizontal",
                                                                                                                                   "Download",
                                                                                                                                   size = "xs",
                                                                                                                      ),
                                                                                                                      style = "padding-bottom:10px"
                                                                                                                    ),
                                                                                                                    selectizeInput(inputId = "input.barplot.horizontal.tax",
                                                                                                                                   label = "Choose taxonomic level",
                                                                                                                                   choices = NULL),
                                                                                                                    plotOutput(outputId = "output.barplot.horizontal", width = "50%")
                                                                                                           ),
                                                                                                           tabPanel("Compressed",
                                                                                                                    tags$div(
                                                                                                                      downloadBttn("download.barplot.compressed",
                                                                                                                                   "Download",
                                                                                                                                   size = "xs",
                                                                                                                      ),
                                                                                                                      style = "padding-bottom:10px"
                                                                                                                    ),
                                                                                                                    selectizeInput(inputId = "input.barplot.compressed.tax",
                                                                                                                                   label = "Choose taxonomic level",
                                                                                                                                   choices = NULL),
                                                                                                                    plotOutput(outputId = "output.barplot.compressed", width = "50%")
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
                                                                                                                      downloadBttn("download.heatmap",
                                                                                                                                   "Download",
                                                                                                                                   size = "xs",
                                                                                                                      ),
                                                                                                                      style = "padding-bottom:10px"
                                                                                                                    ),
                                                                                                                    selectizeInput(inputId = "input.heatmap.tax",
                                                                                                                                   label = "Choose taxonomic level",
                                                                                                                                   choices = NULL),
                                                                                                                    plotOutput(outputId = "output.heatmap", width = "50%")
                                                                                                           ),
                                                                                                           tabPanel("Single var",
                                                                                                                    tags$div(
                                                                                                                      downloadBttn("download.heatmap.univar",
                                                                                                                                   "Download",
                                                                                                                                   size = "xs",
                                                                                                                      ),
                                                                                                                      style = "padding-bottom:10px"
                                                                                                                    ),
                                                                                                                    selectizeInput(inputId = "input.heatmap.univar.tax",
                                                                                                                                   label = "Choose taxonomic level",
                                                                                                                                   choices = NULL),
                                                                                                                    plotOutput(outputId = "output.heatmap.univar", width = "50%")
                                                                                                           ),
                                                                                                           tabPanel("Multi var",
                                                                                                                    tags$div(
                                                                                                                      downloadBttn("download.heatmap.multivar",
                                                                                                                                   "Download",
                                                                                                                                   size = "xs",
                                                                                                                      ),
                                                                                                                      style = "padding-bottom:10px"
                                                                                                                    ),
                                                                                                                    selectizeInput(inputId = "input.heatmap.multivar.tax",
                                                                                                                                   label = "Choose taxonomic level",
                                                                                                                                   choices = NULL),
                                                                                                                    plotOutput(outputId = "output.heatmap.multivar", width = "50%")
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
                                                                                    selectizeInput(inputId = "input.treemap.tax",
                                                                                                   label = "Choose taxonomic level",
                                                                                                   choices = NULL),
                                                                                    selectizeInput(inputId = "input.treemap.tax2",
                                                                                                   label = "Choose second taxonomic level (optional)",
                                                                                                   choices = NULL),
                                                                                    plotOutput(outputId = "output.treemap", width = "50%")
                                                                           ),
                                                                           tabPanel("Differential abundance",
                                                                                    tags$div(
                                                                                      downloadBttn("download.diff_abundance",
                                                                                                   "Download",
                                                                                                   size = "xs",
                                                                                      ),
                                                                                      style = "padding-bottom:10px"
                                                                                    ),
                                                                           ),
                                                                           tabPanel("PCoA",
                                                                                    tags$div(
                                                                                      downloadBttn("download.pcoa",
                                                                                                   "Download",
                                                                                                   size = "xs",
                                                                                      ),
                                                                                      style = "padding-bottom:10px"
                                                                                    ),
                                                                                    selectizeInput(inputId = "input.pcoa.tax",
                                                                                                   label = "Choose taxonomic level",
                                                                                                   choices = NULL),
                                                                                    plotOutput(outputId = "output.pcoa", width = "50%")
                                                                           ),
                                                                           tabPanel("Networks",
                                                                                    tags$div(
                                                                                      downloadBttn("download.networks",
                                                                                                   "Download",
                                                                                                   size = "xs",
                                                                                      ),
                                                                                      style = "padding-bottom:10px"
                                                                                    ),
                                                                                    selectizeInput(inputId = "input.networks.tax",
                                                                                                   label = "Choose taxonomic level",
                                                                                                   choices = NULL),
                                                                                    plotOutput(outputId = "output.networks", width = "50%")
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
