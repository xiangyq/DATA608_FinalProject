library(shiny)
library(leaflet)
library(rCharts)
library(shinythemes)

si <- read.csv('si_df.csv', header = TRUE, stringsAsFactors = FALSE)
neighborhoods <- sort(unique(si$NEIGHBORHOOD))

shinyUI(
  
  navbarPage(
    title = 'STATEN ISLAND Home Sale Explorer',
    theme=shinytheme('cosmo'),
    
    tabPanel(
      title = 'Overview',
      includeHTML("project_overview.html")
    ),
    
    tabPanel(
      title = 'User Exploring',
        titlePanel(""),
        fluidRow(
          column(3,
                 wellPanel(
                   h3("Filter"),
                   selectInput("category","HOME CATEGORY",c("ALL","ONE FAMILY","TWO FAMILY","THREE FAMILY",
                                                            "COOPS - WALKUP","COOPS - ELEVATOR",
                                                            "CONDOS - WALKUP","CONDOS - ELEVATOR")),
                   selectInput("year", "Year", c("ALL",2015,2016)),
                   sliderInput("month", "Month", 1, 12, value = c(1, 12)),
                   sliderInput("price", "Sale Price (thousands)",
                               10, 3800, value=c(10,3800)),
                   selectInput('zipcode','ZIP CODE',c("ALL",10301,10302,10303,10304,10305,10306,
                                                      10307,10308,10309,10310,10312,10314)),
                   selectInput('neighborhood','NEIGHBORHOOD',c('ALL',neighborhoods)
                   )
                 )
          ),
          column(9,
                 wellPanel(
                   span('Number of rows of data selected:',
                        textOutput("dim")
                   )
                 ),
                 tabsetPanel(id='tabSelected',
                             tabPanel('Show Map',showOutput('myMap','leaflet')),
                             tabPanel('Price Plot',plotOutput('pricePlot')),
                             tabPanel('Volume Plot',plotOutput('volumePlot')),
                             tabPanel('Raw Data',dataTableOutput('dataTable')),
                             tabPanel('Download Data', downloadButton('downloadData', 'Download'))
                 )
          )
        ))
    )
  )
