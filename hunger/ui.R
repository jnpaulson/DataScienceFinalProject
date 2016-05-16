library(shiny)
library(ggplot2)
library(ggvis)

xaxisNamesUI =   c("2014 ND-GAIN Country Index (Climate Score)",
                   "2014 ND-GAIN GDP-adjusted Country Index (Climate Score)",
                   "2015 Corruption Perceptions Index",
                   "2015 average of global conflict risk factors of  international conflict, national conflict, unemployment, and repression",
                   "Summary Score For Conflict, Corruption, and Climate")

yaxisNamesUI =   c("2015 Global Hunger Index Scores",
                   "Log10 2015 Gross Domestic Product based on Purchasing-Power-Parity",
                   "2014 Human Development Index")

allNames = c(xaxisNamesUI,yaxisNamesUI)

regions = c("All","Asia","Europe","Africa","Americas")	

googleAnalytics <- function(account="UA-55278636-1"){
  HTML(paste("<script>
             (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
             (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
             m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
             })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
             ga('create', '",account,"', 'shinyapps.io');
             ga('send', 'pageview');
             </script>", sep=""))
}

shinyUI(
  fluidPage(
    titlePanel(
      tags$div(class="header", checked=NA,
               a(href="http://www.bread.org/","Development Builds Resilience"),
               tags$small(p("Use this interactive tool to see how various types of data are related to hunger measures."))
      )
    ),
    sidebarLayout(position="right",
                  sidebarPanel(
                    checkboxInput("countryText","Display Country Labels",value=FALSE),
                    selectInput("regionGroup","Visualize region",regions,regions[1]),
                    selectInput("xaxis","Select a Hunger Indicator",allNames,xaxisNamesUI[1]),
                    selectInput("yaxis","Select an Outcome Predictive of Hunger",allNames,yaxisNamesUI[1]),
                    uiOutput("ggvis_ui")
                  ),
                  mainPanel(
                    googleAnalytics(),
                    ggvisOutput("ggvis"),
                    br(),
                    uiOutput('text')
                  )
    )
  )
)
