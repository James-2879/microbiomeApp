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
    live_data <- datatable(all_samples)
    return(live_data)
  })
  
  reactive.example_table <- reactive({
    example_table <- head(all_samples, n = 5) %>% 
      select(abundance, day, location, type, Taxa)
    example_table <- datatable(example_table, options = list(
      dom = 't'  # Hide header and footer
    ))
    return(example_table)
  })
  
  # Controls ----
  
  reactive.controls <- reactive({
    controls <- plot_controls()
    return(controls)
  })
  
  # Barplots ----
  
  updateSelectizeInput(session, "input.barplot.simple.tax", choices = taxonomy, server = TRUE)
  updateSelectizeInput(session, "input.barplot.stacked.tax", choices = taxonomy, server = TRUE)
  updateSelectizeInput(session, "input.barplot.horizontal.tax", choices = taxonomy, server = TRUE)
  updateSelectizeInput(session, "input.barplot.compressed.tax", choices = taxonomy, server = TRUE)
  
  reactive.barplot.simple <- reactive({
    barplot.simple <- make_barplot(all_samples, classification = input$input.barplot.simple.tax)
    return(barplot.simple)
  })
  
  reactive.barplot.stacked <- reactive({
    barplot.stacked <- make_stacked_barplot(all_samples, classification = input$input.barplot.stacked.tax)
    return(barplot.stacked)
  })
  
  reactive.barplot.horizontal <- reactive({
    barplot.horizontal <- make_horizontal_stacked_barplot(all_samples, classification = input$input.barplot.horizontal.tax)
    return(barplot.horizontal)
  })
  
  reactive.barplot.compressed <- reactive({
    barplot.compressed <- make_compressed_stacked_barplot(all_samples, classification = input$input.barplot.compressed.tax)
    return(barplot.compressed)
  })
  
  # Heatmap ----
  
  updateSelectizeInput(session, "input.heatmap.tax", choices = taxonomy, server = TRUE)
  updateSelectizeInput(session, "input.heatmap.univar.tax", choices = taxonomy, server = TRUE)
  updateSelectizeInput(session, "input.heatmap.multivar.tax", choices = taxonomy, server = TRUE)
  
  reactive.heatmap <- reactive({
    heatmap <- make_heatmap(all_samples, classification = input$input.heatmap.tax)
    return(heatmap)
  })
  
  reactive.heatmap.univar <- reactive({
    heatmap.univar <- make_univar_heatmap(all_samples, classification = input$input.heatmap.univar.tax)
    return(heatmap.univar)
  })
  
  reactive.heatmap.multivar <- reactive({
    heatmap.multivar <- make_multivar_heatmap(all_samples, classification = input$input.heatmap.multivar.tax)
    return(heatmap.multivar)
  })
  
  # Density ----
  
  reactive.density <- reactive({
    density <- make_density_plot(data = all_samples,
                                 limits = c(0, 0.0005))
    return(density)
  })
  
  # Treemap ----
  
  updateSelectizeInput(session, "input.treemap.tax", choices = taxonomy2, server = TRUE)
  updateSelectizeInput(session, "input.treemap.tax2", choices = taxonomy, server = TRUE)
  
  reactive.treemap <- reactive({
    if (input$input.treemap.tax != "none" & input$input.treemap.tax2 == "none") {
      treemap <- make_treemap(data = test_microbiome,
                              classification = input$input.treemap.tax,
                              max = 10)
      return(treemap)
    } else if (input$input.treemap.tax == input$input.treemap.tax2) {
      sendSweetAlert(
        session = getDefaultReactiveDomain(),
        title = "Invalid selection",
        text = paste0("Taxonomic levels should be different, or choose 'none'."),
        type = "error",
        btn_labels = "Understood",
        closeOnClickOutside = FALSE
      )
    } else if (input$input.treemap.tax2 != "none") {
      treemap <- make_dual_treemap(data = test_microbiome,
                                   classification1 = input$input.treemap.tax,
                                   classification2 = input$input.treemap.tax2,
                                   max = 10)
      return(treemap)
    } 
  })
  
  # PCoA ----
  
  updateSelectizeInput(session, "input.pcoa.tax", choices = taxonomy, server = TRUE)
  
  reactive.pcoa <- reactive({
    if (input$input.pcoa.tax != "none") {
      pcoa <- do_pcoa(data = all_samples, 
                      classification = input$input.pcoa.tax)
      return(pcoa)
    }
  })
  
  # Networks ----
  
  updateSelectizeInput(session, "input.networks.tax", choices = taxonomy, server = TRUE)
  
  reactive.networks <- reactive({
    if (input$input.networks.tax != "none") {
      network <- create_network(data = all_samples,
                                taxonomic_level = input$input.networks.tax,
                                max_dist = 1)
      return(network)
    }
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
  
  output$output.barplot.simple <- renderPlot({reactive.barplot.simple()})
  output$output.barplot.stacked <- renderPlot({reactive.barplot.stacked()})
  output$output.barplot.horizontal <- renderPlot({reactive.barplot.horizontal()})
  output$output.barplot.compressed <- renderPlot({reactive.barplot.compressed()})
  
  output$output.heatmap <- renderPlot({reactive.heatmap()})
  output$output.heatmap.univar <- renderPlot({reactive.heatmap.univar()})
  output$output.heatmap.multivar <- renderPlot({reactive.heatmap.multivar()})
  
  output$output.controls <- renderPlot({reactive.controls()})
  output$output.density <- renderPlot({reactive.density()})
  output$output.treemap <- renderPlot({reactive.treemap()})
  output$output.pcoa <- renderPlot({reactive.pcoa()})
  output$output.networks <- renderPlot({reactive.networks()})
  
  output$download.barplot.simple <- download_manager(object = reactive.barplot.simple(), device = "ggsave")
  output$download.barplot.stacked <- download_manager(object = reactive.barplot.stacked(), device = "ggsave")
  output$download.barplot.horizontal <- download_manager(object = reactive.barplot.horizontal(), device = "ggsave")
  output$download.barplot.compressed <- download_manager(object = reactive.barplot.compressed(), device = "ggsave")
  
  output$download.heatmap <- download_manager(object = reactive.heatmap(), device = "ggsave")
  output$download.heatmap.univar <- download_manager(object = reactive.heatmap.univar(), device = "ggsave")
  output$download.heatmap.multivar <- download_manager(object = reactive.heatmap.multivar(), device = "ggsave")
  
  output$download.controls <- download_manager(object = reactive.controls(), device = "ggsave")
  output$download.density <- download_manager(object = reactive.density(), device = "ggsave")
  output$download.treemap <- download_manager(object = reactive.treemap(), device = "ggsave")
  output$download.pcoa <- download_manager(object = reactive.pcoa(), device = "ggsave")
  output$download.networks <- download_manager(object = reactive.networks(), device = "ggsave")
  
  
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
