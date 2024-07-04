source("global.R", local = TRUE)
source("themes.R", local = TRUE)

# for contents, look bottom-left in this panel of Rstudio IDE

server <- function(input, output, session){
  
  #--------------------------------- Variables ---------------------------------
  
  values <- reactiveValues() # initialize
  # values$var etc.
  
  values$user_data <- NULL
  
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
    req(values$user_data)
    live_data <- datatable(values$user_data)
    return(live_data)
  })
  
  reactive.example_table <- reactive({
    req(values$user_data)
    example_table <- values$user_data %>% 
      select(species, taxonomy, abundance) %>% 
      head(., n = 5)
    example_table <- datatable(example_table, options = list(
      dom = 't'  # Hide header and footer
    ))
    return(example_table)
  })
  
  # Data upload ----
  
  observeEvent(input$user.upload.single, {
    confirmSweetAlert(
      session = getDefaultReactiveDomain(),
      inputId = "file_uploaded",
      title = "Upload abundance file",
      text = tags$div(align = "center",
                      fluidRow(
                        column(width = 12,
                               fileInput(
                                 inputId = "uploaded_user_file",
                                 label = NULL,
                                 multiple = FALSE,
                                 accept = c(".tsv"),
                                 width = NULL,
                                 buttonLabel = "Browse...",
                                 placeholder = "No file selected"
                               ),
                               tags$span("Note: only TSV files are currently accepted")
                        ),
                        style = "width: 100%; margin: 30px, align: center;"
                      )
      ),
      type = NULL,
      allowEscapeKey = TRUE,
      cancelOnDismiss = TRUE,
      closeOnClickOutside = TRUE,
      btn_labels = c("Cancel" ,"Continue")
    )
  })
  
  observeEvent(input$user.upload.zip, {
    confirmSweetAlert(
      session = getDefaultReactiveDomain(),
      inputId = "zip_uploaded",
      title = "Upload ZIP file",
      text = tags$div(align = "center",
                      fluidRow(
                        column(width = 12,
                               fileInput(
                                 inputId = "uploaded_user_zip",
                                 label = NULL,
                                 multiple = FALSE,
                                 accept = c(".zip"),
                                 width = NULL,
                                 buttonLabel = "Browse...",
                                 placeholder = "No file selected"
                               ),
                               tags$span("Note: only ZIP files are currently accepted")
                        ),
                        style = "width: 100%; margin: 30px, align: center;"
                      )
      ),
      type = NULL,
      allowEscapeKey = TRUE,
      cancelOnDismiss = TRUE,
      closeOnClickOutside = TRUE,
      btn_labels = c("Cancel" ,"Continue")
    )
  })
  
  observeEvent(input$file_uploaded, {
    loaded_data <- load_user_data(input$uploaded_user_file$datapath)
    tryCatch(
      expr = {
      check_data(loaded_data)
      values$user_data <- loaded_data
      sendSweetAlert(
        session = getDefaultReactiveDomain(),
        title = "Done",
        type = "success",
        text = "Uploaded data is now live in-app."
      )
      Sys.sleep(1.75)
      closeSweetAlert(session = getDefaultReactiveDomain())
      }, error = function(e) {
        sendSweetAlert(
          session = getDefaultReactiveDomain(),
          title = "Error",
          type = "error",
          text = "Data not in expected format."
        )
      }
    )
  })
  
  observeEvent(input$zip_uploaded, {
    
    zip_path <- input$uploaded_user_zip$datapath
    
    # Define the directory to extract to
    extraction_dir <- file.path(tempdir(), "extracted_files")
    
    if (dir.exists(extraction_dir)) {
      unlink(extraction_dir, recursive = TRUE)
    }
    
    # Create the directory if it doesn't exist
    if (!dir.exists(extraction_dir)) {
      dir.create(extraction_dir)
    }

    unzip(zipfile = zip_path, exdir = extraction_dir)
    
    dirs <- list.dirs(extraction_dir, recursive = FALSE)
    dirs <- paste0(dirs, "/")
 
    loaded_data <- load_user_data_dir(dirs)
    
    tryCatch(
      expr = {
        check_data(loaded_data)
        values$user_data <- loaded_data
        sendSweetAlert(
          session = getDefaultReactiveDomain(),
          title = "Done",
          type = "success",
          text = "Uploaded data is now live in-app."
        )
        Sys.sleep(1.75)
        closeSweetAlert(session = getDefaultReactiveDomain())
      }, error = function(e) {
        sendSweetAlert(
          session = getDefaultReactiveDomain(),
          title = "Error",
          type = "error",
          text = "Data not in expected format."
        )
      }
    )
  })
  
  # Barplots ----
  
  reactive.barplot.simple <- reactive({
    req(values$user_data)
    plot <-  make_barplot(values$user_data, max = 6, orientation = "horizontal")
    return(plot)
  })
  
  reactive.barplot.stacked <- reactive({
    req(values$user_data)
    plot <- make_stacked_barplot(values$user_data, orientation = "vertical", max = 10)
    return(plot)
  })
  
  # Controls ----
  
  reactive.controls <- reactive({
    req(values$user_data)
    plot <- plot_controls(values$user_data)
    return(plot)
  })
  
  # Density ----
  
  reactive.density <- reactive({
    req(values$user_data)
    plot <- make_density_plot(values$user_data)
    return(plot)
  })
  
  # Heat maps ----
  
  reactive.heatmap.simple <- reactive({
    req(values$user_data)
    plot <-  make_heatmap(values$user_data)
    return(plot)
  })
  
  reactive.heatmap.clustered <- reactive({
    req(values$user_data)
    plot <-  make_clustered_heatmap(values$user_data)
    return(plot)
  })
  
  # Network ----
  
  reactive.network <- reactive({
    req(values$user_data)
    physeq_object <- create_physeq_object(data = values$user_data)
    plot <- create_network_phyloseq(physeq_object = physeq_object,
                                    distance_method = "bray",
                                    max_dist = 0.5)
    return(plot)
  })
  
  # PCoA ----
  
  reactive.pcoa <- reactive({
    req(values$user_data)
    plot <-   do_pcoa(values$user_data, zero_missing = TRUE)
    return(plot)
  })
  
  # Tree map ----
  
  reactive.treemap <- reactive({
    req(values$user_data)
    plot <-   make_treemap(values$user_data, max = 10)
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
  
  observe({
    if (is.null(values$user_data)) {
      output$output.live_data.text <- renderText({"Start by adding data in the 'Upload data' tab."})
    } else {
      output$output.live_data.text <- renderText({"Displaying data currently used in-app."})
    }
  })
  
  output$output.example_table <- renderDataTable({reactive.example_table()})
  output$output.example_table.text <- renderText({"Data should contain three columns (species, taxonomy, abundance), 
    although column order is irrelevant. Any extra columns will be ignored"})
  output$output.upload.help <- renderText({"To upload one or multiple directories, package them as ZIP files first."})
  
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
  
}
