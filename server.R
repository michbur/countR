library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  null_input <- reactive({
    is.null(input[["input_file"]]) && input[["run_example"]] == 0
  })
  
  processed_data <- reactive({
    #after loading any file it would be possible to start an example
    if(is.null(input[["input_file"]])) {
      dat <- read.csv("example_data.csv")
    } else {
      dat <- switch(input[["csv_type"]], 
                    csv1 = read.csv(input[["input_file"]][["datapath"]], 
                                    header = input[["header"]]),
                    csv2 = read.csv2(input[["input_file"]][["datapath"]], 
                                     header = input[["header"]]))
      # if(input[["header"]])
      # remove header if it is present 

    }
    
    dat
  })
  
  #dabset before and after data input
  output[["dynamic_tabset"]] <- renderUI({
    if(null_input()) {
      tabPanel("No input detected",
               HTML("No input detected. <br> Select input file or example using the left panel."))
    } else {
      tabsetPanel(
        #tabPanel("Results with graphics", htmlOutput("whole.report")),
        tabPanel("Input data", tableOutput("input_data"))
      )
    }
  })
  
  
  output[["input_data"]] <- renderTable({
    processed_data()
  })
  
})
