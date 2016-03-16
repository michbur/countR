library(shiny)

shinyUI(pageWithSidebar(
  headerPanel("countR"),
  sidebarPanel(
    #includeMarkdown("readme.md"),
    p("Lost? Use button below to see an example:"),
    actionButton("run_example", "Run example"),
    br(), br(),
    fileInput("input_file", "Choose CSV File with count data",
              accept=c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
    checkboxInput("header", "Header", TRUE),
    radioButtons("csv_type", "Type of csv file",
                 c("Dec: dot (.), Sep: comma (;)" = "csv1",
                   "Dec: comma (,), Sep: semicolon (;)" = "csv2"))
    # downloadButton("result.download", "Download report")    
  ),
  mainPanel(
    uiOutput("dynamic_tabset") 
  )
)
)