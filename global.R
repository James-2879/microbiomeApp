#---------------------------------- Libraries ----------------------------------

suppressPackageStartupMessages({
  library(tidyverse) # data wrangling
  library(shiny) # app
  library(shinydashboard) # add sidebar to UI
  library(shinyWidgets) # better widgets than Shiny standard
  library(shinyBS) # UI
  library(shinybusy) # loading modals
  library(bsplus) # UI
  library(ggpubr) # plots
  # library(Cairo) # graphics
  library(DT) # tables
  library(ComplexHeatmap) # heatmap
  library(markdown) # display markdown documents
  library(shinyjs) # JS support
  library(V8) # JS add-on
  library(sendmailR) # bug reports and feature requests
  library(docstring) # Roxygen style docstrings
})

# options(shiny.usecairo = T) # better graphics!

#----------------------------------- Setup -------------------------------------

maintainer <- "james.swift"
# application_path <- "/srv/shiny-server/microbiome_webapp/" # DEPLOYMENT
application_path <- "/home/james/Documents/microbiome_webapp/"
# modules_path <- "/srv/shiny-server/microbiome_webapp/microbiome_analysis/"# DEPLOYMENT
modules_path <- "/home/james/Documents/microbiome_analysis/"


#---------------------------------- Modules ------------------------------------

source(paste0(modules_path, "tools/themes.R"))
source(paste0(modules_path, "tools/controls.R"))
source(paste0(modules_path, "tools/treemap.R"))
source(paste0(modules_path, "tools/density.R"))
source(paste0(modules_path, "tools/barplot.R"))
source(paste0(modules_path, "tools/pcoa.R"))
source(paste0(modules_path, "tools/heatmap.R"))
source(paste0(modules_path, "tools/co_network.R"))
source(paste0(modules_path, "tools/cross_feeding_network.R"))

# source(paste0(modules_path, "tools/data.R"))
# load_data(path = modules_path)

#---------------------------------- Metadata -----------------------------------

taxonomy2 <- c("none",
              "domain",
              "kingdom",
              "phylum",
              "class",
              "order",
              "family",
              "genus",
              "species")

taxonomy <- taxonomy2[taxonomy2 != "none"] # remove none value
