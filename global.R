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

#---------------------------------- Modules ------------------------------------

# Construct directory ----

home_dir <- Sys.getenv("HOME")
package_dir <- file.path(home_dir, "Documents", "microbiome_analysis")

# Source required scripts ----

source(file.path(package_dir, "R", "data.R"))
source(file.path(package_dir, "R", "themes.R"))
source(file.path(package_dir, "R", "controls.R"))
source(file.path(package_dir, "R", "treemap.R"))
source(file.path(package_dir, "R", "density.R"))
source(file.path(package_dir, "R", "barplot.R"))
source(file.path(package_dir, "R", "pcoa.R"))
source(file.path(package_dir, "R", "heatmap.R"))
source(file.path(package_dir, "R", "co_network.R"))

# Load documentation ----

# Only if not installed as package
library("roxygen2")
roxygen2::roxygenise(package.dir = package_dir)

#---------------------------------- Metadata -----------------------------------

