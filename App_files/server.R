library(shiny)
library(dplyr)
library(lubridate)
library(knitr)
library(ggplot2)
library(leaflet)
library(rCharts)
library(scales)

# load the data
si <- read.csv('si_df.csv', header = TRUE, stringsAsFactors = FALSE)
nc <- ncol(si)
si <- si[,c(2:nc)]
si$Year <- year(si$SALE.DATE)
si$Month <- month(si$SALE.DATE)

neighborhoods <- unique(si$NEIGHBORHOOD)
zipcodes <- unique(si$ZIP.CODE)


function(input, output) {
  
  # Filter the data
  si_df <- reactive({
    zipcode <- input$zipcode
    minmonth <- input$month[1]
    maxmonth <- input$month[2]
    minprice <- input$price[1] * 1000
    maxprice <- input$price[2] * 1000
    
    # Apply filters
    m <- si %>%
      filter(
        Month >= minmonth,
        Month <= maxmonth,
        SALE.PRICE >= minprice,
        SALE.PRICE <= maxprice
      )
    
    if (input$category != "ALL") {
      m <- m %>% 
        filter(BUILDING.CLASS.CATEGORY == input$category)
    } else {
      m <- m
    }
    
    if (input$year != "ALL") {
      m <- m %>% 
        filter(Year == input$year)
    } else {
      m <- m
    }
    
    if (input$zipcode != 'ALL') {
      
      m <- m %>% filter(ZIP.CODE==input$zipcode)
    } else {
      m <- m
    }
    
    if (!is.null(input$neighborhood) && input$neighborhood %in% neighborhoods) {
      
      m <- m %>% filter(NEIGHBORHOOD==input$neighborhood)
    } else {
      m <- m
    }
    
    m <- as.data.frame(m)
  })
  

  output$dim <- renderText({ dim(si_df())[1] })
  
  
  output$dataTable <- renderDataTable({si_df()[,1:8]})
  
  output$downloadData <- downloadHandler(
    filename = function() { 
      paste('user_selected', '.csv', sep='') 
    },
    content = function(file) {
      write.csv(si_df()[,1:8], file)
    }
  )
  
  output$pricePlot <- renderPlot({
    si <- si_df()
    n1 <- dim(si)[1]
    if (n1 >= 1) {
      df_1 <- si %>%
        group_by(yr=year(SALE.DATE),mon=month(SALE.DATE)) %>%
        summarise(Average.Price=mean(SALE.PRICE))
      
      df_1$Date <- as.Date(paste(df_1$yr,df_1$mon,'01',sep='-'))
      df_1 <- df_1[,3:4]
      p1 <- ggplot(data=df_1, aes(x=Date, y=Average.Price, group=1)) + 
        geom_point() +
        geom_line() +
        scale_y_continuous(labels=comma) +
        labs(title='Monthly Average Home Sale Price', y='', x= '')
      p1
    }
  })
  
  output$volumePlot <- renderPlot({
    si <- si_df()
    n2 <- dim(si)[1]
    if (n2>=1) {
      df_2 <- si %>%
        group_by(yr=year(SALE.DATE),mon=month(SALE.DATE)) %>%
        summarise(count=n())
      
      df_2$Date <- as.Date(paste(df_2$yr,df_2$mon,'01',sep='-'))
      df_2 <- df_2[,3:4]
      p2 <- ggplot(data=df_2, aes(x=Date, y=count, group=1)) + 
        geom_point() +
        geom_line() + 
        labs(title='Monthly Home Sale Count', y='', x='')
      p2
    }
  })
  
  output$myMap <- renderMap({
    si <- si_df()
    map <- Leaflet$new()
    map$setView(c(40.5795,-74.1502),zoom=8)
    map$tileLayer(provide='Esri.WorldTopoMap')
    for (i in 1:nrow(si)) {map$marker(c(si[i,'Latitude'],si[i,'Longtitude']),
                                      bindPopup=si[i,'ADDRESS'])}
    map$enablePopover(TRUE)
    map
  })

}
