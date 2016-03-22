library(shiny)
library(DT)
library(reshape2)
library(ggplot2)
source("load_all.R")

options(DT.options = list(dom = 'T<"clear">lfrtip',
                          tableTools = list(sSwfPath = copySWF("./www/"),
                                            aButtons = list(
                                              "copy",
                                              "print",
                                              "csv"
                                            )
                          )
))

my_DT <- function(x)
  datatable(x, escape = FALSE, extensions = 'TableTools', 
            filter = "top", rownames = FALSE)


shinyServer(function(input, output) {
  
  raw_counts <- reactive({
    # if there is no data, example is loaded
    if(is.null(input[["input_file"]])) {
      dat <- read.csv("example_counts.csv")
    } else {
      dat <- switch(input[["csv_type"]], 
                    csv1 = read.csv(input[["input_file"]][["datapath"]], 
                                    header = input[["header"]]),
                    csv2 = read.csv2(input[["input_file"]][["datapath"]], 
                                     header = input[["header"]]))
      if(!input[["header"]])
        colnames(dat) <- paste0("C", 1L:ncol(dat))
      
    }
    
    dat
  })
  
  processed_counts <- reactive({
    process_counts(raw_counts())
  })
  
  occs <- reactive({
    get_occs(processed_counts())
  })
  
  fits_separate <- reactive({
    fit_counts(processed_counts(), separate = TRUE, model = "all")
  })
  
  fits_whole <- reactive({
    fit_counts(processed_counts(), separate = FALSE, model = "all")
  })
  
  output[["input_data"]] <- DT::renderDataTable({
    my_DT(raw_counts())
  })
  
  output[["input_data_summary"]] <- DT::renderDataTable({
    my_DT(summary_counts(processed_counts()))
  })
  
  output[["input_data_distr_tab"]] <- DT::renderDataTable({
    dat <- dcast(occs(), x ~ count, value.var = "n")
    colnames(dat)[1] <- "Count"
    my_DT(dat)
  })
  
  output[["input_data_distr_plot"]] <- renderPlot({
    plot_occs(occs())
  })
  
  output[["input_data_distr_plot_ui"]] <- renderUI({
    plotOutput("input_data_distr_plot", 
               height = 260 + 70 * length(processed_counts()))
  })  
  
  output[["input_data_distr_plot_db"]] <- downloadHandler("distr_barplot.svg",
                                                          content = function(file) {
                                                            ggsave(file, plot_occs(occs()), device = svg, 
                                                                   height = 260 + 70 * length(processed_counts()), width = 297,
                                                                   units = "mm")
                                                          })
  # separate fits  ----------------------------
  output[["fit_sep_plot"]] <- renderPlot({
    plot_fitlist(fits_separate(), input[["models_fit_sep_plot"]])
  })
  
  output[["fit_sep_plot_db"]] <- downloadHandler("fit_sep_CI.svg",
                                                          content = function(file) {
                                                            ggsave(file, plot_fitlist(fits_separate(), input[["models_fit_sep_plot"]]),
                                                                   device = svg, 
                                                                   height = 297, width = 297,
                                                                   units = "mm")
                                                          })
  
  output[["fit_sep_tab"]] <- DT::renderDataTable({
    my_DT(summary_fitlist(fits_separate())[, c("count", "lambda", "lower", "upper", "BIC", "model")])
  })
  
  # whole fits  ----------------------------
  output[["fit_whole_plot"]] <- renderPlot({
    plot_fitlist(fits_whole(), input[["models_fit_whole_plot"]])
  })
  
  output[["fit_whole_plot_db"]] <- downloadHandler("fit_whole_CI.svg",
                                                 content = function(file) {
                                                   ggsave(file, plot_fitlist(fits_whole(), input[["models_fit_whole_plot"]]),
                                                          device = svg, 
                                                          height = 297, width = 297,
                                                          units = "mm")
                                                 })
  
  output[["fit_whole_tab"]] <- DT::renderDataTable({
    my_DT(summary_fitlist(fits_whole())[, c("count", "lambda", "lower", "upper", "BIC", "model")])
  })
  
})
