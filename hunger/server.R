library(shiny)
library(ggplot2)
library(ggvis)

xaxisChoices=
  c("Climate_NominalScore",
 "Climate_AdjustedScore",
 "Corruption_Score",
 "Average_Conflict",
 "Summary_ZScore_2",
 "Hunger_Score",
 "GDP", 
 "HDI_2014")
#Make sure to include the y-axis at the bottom

xaxisNames = 
  c("2014 ND-GAIN Country Index (Climate Score)",
    "2014 ND-GAIN GDP-adjusted Country Index (Climate Score)",
    "2015 Corruption Perceptions Index",
    "2015 average of global conflict risk factors of  international conflict, national conflict, unemployment, and repression",
    "Summary Score For Conflict, Corruption, and Climate",
    "2015 Global Hunger Index Scores",
    "Log10 2015 Gross Domestic Product based on Purchasing-Power-Parity",
    "2014 Human Development Index")


df = read.csv("./combinedData.csv")
df_complete = na.omit(df)
df_complete$GDP <- log10(df_complete$GDP)
Region = factor(df_complete[,'continent'])
names(Region) = df_complete[,'Country']
rownames(df_complete) = df_complete[,'Country']
df_complete = df_complete[,-c(1:2)]
df_complete = df_complete[,xaxisChoices]
colnames(df_complete) = xaxisNames
df_complete = cbind(df_complete,Region)

all_values <- function(x) {
  if(is.null(x)) return(NULL)
  paste0(names(x)[1:2], ": ", format(x)[1:2], collapse = "<br />")
}
shinyServer(function(input, output) {
  
  df <- reactive({
    dataframe = data.frame(x=df_complete[,input$xaxis],y=df_complete[,input$yaxis],
                           country=rownames(df_complete),Regions=df_complete[,"Region"])
    if(input$regionGroup!="All"){
      dataframe = dataframe[dataframe$Regions==input$regionGroup,]
    }
    dataframe = na.omit(dataframe)
    dataframe
  })
  
  reactive({
    maxx = max(df()$x,na.rm=TRUE)
    maxy = max(df()$y,na.rm=TRUE)
    
    base <- df() %>% ggvis(x=~x,y=~y) %>%
      layer_points(size=100,fill.update=~Regions) %>% 
      add_tooltip(all_values,"hover") %>%
      add_axis("y", title = input$yaxis) %>% 
      scale_numeric("y", domain = c(0, maxy), nice = FALSE, clamp = TRUE) %>%
      layer_smooths(span=1) %>%
      add_axis("x",title=input$xaxis) 
    
    if(input$countryText==TRUE){
      base <- base %>% layer_text(text.hover:=~country,text.update:=~country)
    }
    base
  }) %>% bind_shiny("ggvis", "ggvis_ui")
  
  
  output$text<-renderText({
    HTML("Notes on X-axis scales:
<p> A higher ND-GAIN score indicates more capacity to deal with potential climate risk
<p> A higher Corruption Perceptions Index means little perceived corruption
<p> A higher Global Conflict Risk Index indicates more conflict
<p> A higher Global Hunger Index Score means more hunger 
<p> A higher Human Development Index means a higher level of social and economic development
<p> A higher summary score for conflict, corruption, and climate indicates that the country is performing above-average on the 3Cs relative to other countries
</p><br>
<p>Github repository for data aggregation and sources <a href='https://github.com/elc013/DataScienceFinalProject'>available here</a> 
<p> Visualization based on shiny app written by <a href='http://www.cbcb.umd.edu/~jpaulson/'>Joseph N. Paulson</a> and <a href='https://github.com/khughitt'>Keith Hughitt</a>")
  })
  
})

#https://www.shinyapps.io/admin/#/dashboard (how to work with it)