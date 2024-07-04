source("global.R", local = TRUE)
source("themes.R", local = TRUE)

# for contents, look bottom-left in this panel of Rstudio IDE

server <- function(input, output, session){
  
  #--------------------------------- Variables ---------------------------------
  
  values <- reactiveValues() # initialize
  # values$var etc.
  
  #--------------------------------- Functions ---------------------------------
  
  `%ni%` <- Negate(`%in%`)
  
  update_theme <- function(grids, size, rotate = NULL) {
    #' Update themes for ggplots.
    #' 
    #' Changes text sizes, whether a grid is applied to the plot, and whether axis labels should be rotated.
    
    # grid lines and extra size
    if (grids == FALSE & size == FALSE) {
      theme <- theme_blank_with_legend
    } else if (grids == FALSE & size == TRUE) {
      theme <- theme_blank_with_legend_large
    } else if (grids == TRUE & size == FALSE) {
      theme <- theme_grids_with_legend
    } else if (grids == TRUE & size == TRUE) {
      theme <- theme_grids_with_legend_large
    }
    # rotate axis labels
    if (is.null(rotate) == FALSE) {
      if (rotate == TRUE) {
        element <- list(theme(axis.text.x = element_text(angle = 45, margin = margin(t=30))))
        theme <- append(theme, element)
      } else if (rotate == FALSE) {
        element <- list(theme(axis.text.x = element_text(angle = 0)))
        theme <- append(theme, element)
      }
    }
    return(theme)
  }
  
  download_manager <- function(device, object, file_name = NULL, width = NULL, height = NULL) {
    #' Manage downloads for the majority of objects.
    #'
    #' Handles downloads for ggplots, non-ggplot objects/plots, and text objects (notably dataframes).
    #' Using Cairo for ggplots anyway may increase quality in some circumstances.
    if (is.null(file_name) == TRUE) {
      if (device != "text") {
        file_name <- paste0(Sys.Date(), "_plot.jpeg")
      } else if (device == "text") {
        file_name <- paste0(Sys.Date(), "_data.tsv")
      }
    }
    if (is.null(width) == TRUE & device != "text") {
      width <- 1280 # random default
    }
    if (is.null(height) == TRUE & device != "text") {
      height <- 720 # random default
    }
    if (device == "ggsave") { # for plots
      output <- downloadHandler(filename = file_name,
                                content = function(file) {
                                  ggsave(
                                    filename = file,
                                    plot = object, # plot to download goes here
                                    device = "jpeg",
                                    width = width * 5,
                                    height = height * 5,
                                    units = "px",
                                    dpi = 300
                                  )
                                  isolate(values$download_flag <- values$download_flag + 1)
                                }
      ) 
    } else if (device == "cairo") { # for plots - generally gives better resolutions
      output <- downloadHandler(filename = file_name,
                                content = function(file) {
                                  CairoPNG(
                                    filename = file,
                                    width = width * 5,
                                    height = height * 5,
                                    dpi = 300
                                  )
                                  print(object) # plot var goes in here
                                  dev.off()
                                  isolate(values$download_flag <- values$download_flag + 1)
                                }
      )
    } else if (device == "text") { # for CSVs
      output <- downloadHandler(filename = file_name,
                                content = function(file) {
                                  write_tsv(object, file) # table to download goes here
                                  isolate(values$download_flag <- values$download_flag + 1)
                                }
      )
    }
    return(output)
  }
  
  
  #--------------------------------- Switches ----------------------------------
  
  # Data ----
  
  reactive.live_data <- reactive({
    live_data <- datatable(user_data)
    return(live_data)
  })
  
  reactive.example_table <- reactive({
    example_table <- user_data %>% 
      select(species, taxonomy, abundance) %>% 
      head(., n = 5)
    example_table <- datatable(example_table, options = list(
      dom = 't'  # Hide header and footer
    ))
    return(example_table)
  })
  
  # Barplots ----
  
  reactive.barplot.simple <- reactive({
    plot <-  make_barplot(user_data, max = 6, orientation = "horizontal")
    return(plot)
  })
  
  reactive.barplot.stacked <- reactive({
    plot <- make_stacked_barplot(user_data, orientation = "vertical", max = 10)
    return(plot)
  })
  
  # Controls ----
  
  reactive.controls <- reactive({
    plot <- plot_controls(user_data)
    return(plot)
  })
  
  # Density ----
  
  reactive.density <- reactive({
    plot <- make_density_plot(user_data)
    return(plot)
  })
  
  # Heat maps ----
  
  reactive.heatmap.simple <- reactive({
    plot <-  make_heatmap(user_data)
    return(plot)
  })
  
  reactive.heatmap.clustered <- reactive({
    plot <-  make_clustered_heatmap(user_data)
    return(plot)
  })
  
  # Network ----
  
  reactive.network <- reactive({
    physeq_object <- create_physeq_object(data = user_data)
    plot <- create_network_phyloseq(physeq_object = physeq_object,
                                    distance_method = "bray",
                                    max_dist = 0.5)
    return(plot)
  })
  
  # PCoA ----
  
  reactive.pcoa <- reactive({
    plot <-   do_pcoa(user_data, zero_missing = TRUE)
    return(plot)
  })
  
  # Tree map ----
  
  reactive.treemap <- reactive({
    plot <-   make_treemap(user_data, max = 10)
    return(plot)
  })
  
  
  
  #---------------------------------- Messages ---------------------------------
  
  # help messages
  # observeEvent(input$getting_started_help, {
  #   sendSweetAlert(
  #     session = getDefaultReactiveDomain(),
  #     title = "Getting started",
  #     text = tags$div(includeMarkdown("www/help_files/getting_started_help.md")),
  #     type = "info"
  #     # width = "50%"
  #   )
  # })
  
  #-------------------------------- Downloads ----------------------------------
  
  # observeEvent(values$download_flag, {
  #   values$download_flag <- 0
  #   show_alert(
  #     inputId = "download_successful",
  #     title = "Download successful",
  #     type = "success"
  #   )
  #   output$download_boxplot <- NULL # this is to clear any cache which results in downloads
  #   output$download_boxplot_data <- NULL # not returning the most up-to-date version of an object
  # })
  # 
  # output$download_boxplot <- download_manager(object = boxplot(), device = "ggsave")
  
  
  #--------------------------------- Outputs -----------------------------------
  
  observeEvent(values$download_flag, {
    values$download_flag <- 0
    show_alert(
      inputId = "download_successful",
      title = "Download successful",
      type = "success"
    )
  })
  
  # plot styling options
  output$output.live_data <- renderDataTable({reactive.live_data()})
  output$output.live_data.text <- renderText({"Displaying data currently used in-app."})
  output$output.example_table <- renderDataTable({reactive.example_table()})
  output$output.example_table.text <- renderText({"Data should use the following structure, 
    although column order is irrelevant."})
  
  # Plot outputs ----
  output$output.barplot.simple <- renderPlot({reactive.barplot.simple()})
  output$output.barplot.stacked <- renderPlot({reactive.barplot.stacked()})
  
  output$output.controls <- renderPlot({reactive.controls()})
  
  output$output.density <- renderPlot({reactive.density()})
  
  output$output.heatmap.simple <- renderPlot({reactive.heatmap.simple()})
  output$output.heatmap.clustered <- renderPlot({reactive.heatmap.clustered()})
  
  output$output.network <- renderPlot({reactive.network()})
  
  output$output.pcoa <- renderPlot({reactive.pcoa()})
  
  output$output.treemap <- renderPlot({reactive.treemap()})
  
  
  
  # Downloads ----
  
  output$download.barplot.simple <- download_manager(object = reactive.barplot.simple(), device = "ggsave")
  output$download.barplot.stacked <- download_manager(object = reactive.barplot.stacked(), device = "ggsave")
  
  output$download.controls <- download_manager(object = reactive.controls(), device = "ggsave")
  
  output$download.density <- download_manager(object = reactive.density(), device = "ggsave")
  
  output$download.heatmap.simple <- download_manager(object = reactive.heatmap.simple(), device = "ggsave")
  output$download.heatmap.clustered <- download_manager(object = reactive.heatmap.clustered(), device = "ggsave")
  
  output$download.network <- download_manager(object = reactive.network(), device = "ggsave")

  output$download.pcoa <- download_manager(object = reactive.pcoa(), device = "ggsave")
  
  output$download.treemap <- download_manager(object = reactive.treemap(), device = "ggsave")
 
  
 
  
  
  #--------------------------- gene upload garbage ----
  
  
  
  #' observeEvent(input$gene_upload, {
  #'   #' UI to upload a list of genes.
  #'   confirmSweetAlert(
  #'     session = getDefaultReactiveDomain(),
  #'     inputId = "gene_list_uploaded",
  #'     title = "Upload gene list",
  #'     text = tags$div(align = "center",
  #'                     fluidRow(
  #'                       column(width = 12,
  #'                              fileInput(
  #'                                inputId = "upload_gene_list",
  #'                                label = NULL,
  #'                                multiple = FALSE,
  #'                                accept = c(".tsv", ".csv", ".txt"),
  #'                                width = NULL,
  #'                                buttonLabel = "Browse...",
  #'                                placeholder = "No file selected"
  #'                              ),
  #'                              tags$span("Note: any genes which are not in the correct format will be ignored.")
  #'                       ),
  #'                       style = "width: 100%; margin: 30px, align: center;" 
  #'                     ),
  #'     ),
  #'     type = NULL,
  #'     allowEscapeKey = TRUE,
  #'     cancelOnDismiss = TRUE,
  #'     closeOnClickOutside = TRUE,
  #'     btn_labels = c("Cancel" ,"Continue")
  #'   )
  #' })
  
}
