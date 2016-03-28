library(shiny)
library(shinythemes)

shinyUI(navbarPage(title = "countR",
                   theme = shinytheme("cerulean"),
                   id = "navbar", windowTitle = "countR", collapsible=TRUE,
                   tabPanel("Data upload",
                            includeMarkdown("./readmes/data_upload/1.md"),
                            fluidRow(column(3, fileInput("input_file", "Choose CSV File with count data",
                                                         accept=c("text/csv", "text/comma-separated-values,text/plain", ".csv"))),
                                     column(3, checkboxInput("header", "Header", TRUE)),
                                     column(2, radioButtons("csv_type", "Type of csv file",
                                                            c("Dec: dot (.), Sep: comma (;)" = "csv1",
                                                              "Dec: comma (,), Sep: semicolon (;)" = "csv2")))
                            )
                   ), 
                   navbarMenu("Count data",
                              tabPanel("Count table",
                                       includeMarkdown("./readmes/count_data/1.md"),
                                       DT::dataTableOutput("input_data")
                              ),
                              tabPanel("Summary",
                                       includeMarkdown("./readmes/count_data/2.md"),
                                       DT::dataTableOutput("input_data_summary")
                              ),
                              tabPanel("Distribution",
                                       includeMarkdown("./readmes/count_data/3.md"),
                                       fluidRow(column(3, downloadButton("input_data_distr_plot_db", 
                                                                         "Save chart (.svg)"))),
                                       uiOutput("input_data_distr_plot_ui"),
                                       includeMarkdown("./readmes/count_data/4.md"),
                                       DT::dataTableOutput("input_data_distr_tab")
                              )
                   ),
                   navbarMenu("Mean value estimates",
                              tabPanel("Separate models",
                                       includeMarkdown("./readmes/mean_value/1.md"),
                                       fluidRow(column(3, downloadButton("fit_sep_plot_db", "Save chart (.svg)")),
                                                column(3, checkboxGroupInput("models_fit_sep_plot", "Models to plot", 
                                                                             choices = c("Poisson" = "pois",
                                                                                         "NB" = "nb",
                                                                                         "ZIP" = "zip",
                                                                                         "ZINB" = "zinb"), 
                                                                             selected = c("pois", "nb", "zip", "zinb")
                                                ))
                                       ),
                                       plotOutput("fit_sep_plot"),
                                       includeMarkdown("./readmes/mean_value/2.md"),
                                       DT::dataTableOutput("fit_sep_tab")
                              ),
                              tabPanel("Single model",
                                       includeMarkdown("./readmes/mean_value/3.md"),
                                       fluidRow(column(3, downloadButton("fit_whole_plot_db", "Save chart (.svg)")),
                                                column(3, checkboxGroupInput("models_fit_whole_plot", "Models to plot",
                                                                             choices = c("Poisson" = "pois",
                                                                                         "NB" = "nb",
                                                                                         "ZIP" = "zip",
                                                                                         "ZINB" = "zinb"),
                                                                             selected = c("pois", "nb", "zip", "zinb")
                                                ))
                                       ),
                                       plotOutput("fit_whole_plot"),
                                       includeMarkdown("./readmes/mean_value/4.md"),
                                       DT::dataTableOutput("fit_whole_tab")
                              )
                   ),
                   navbarMenu("Compare distributions",
                              tabPanel("Separate models",
                                       includeMarkdown("./readmes/cmp_distr/1.md"),
                                       fluidRow(column(3, downloadButton("cmp_sep_plot_db", "Save chart (.svg)"))),
                                       plotOutput("cmp_sep_plot"),
                                       DT::dataTableOutput("cmp_sep_tab")
                              ),
                              tabPanel("Single model",
                                       includeMarkdown("./readmes/cmp_distr/2.md"),
                                       fluidRow(column(3, downloadButton("cmp_whole_plot_db", "Save chart (.svg)"))),
                                       plotOutput("cmp_whole_plot"),
                                       DT::dataTableOutput("cmp_whole_tab")
                              )
                   ),
                   navbarMenu("Help",
                              tabPanel("About",
                                       includeMarkdown("./readmes/about.md")),
                              tabPanel("Help",
                                       includeHTML("./readmes/manual.html"))
                   )
))
