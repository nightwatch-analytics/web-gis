library(shiny)
library(bslib)
library(leaflet)
library(tidycensus)
options(tigris_use_cache = TRUE)

ui <- page_sidebar(
  title = "Median age explorer",
  sidebar = sidebar(
    p("This app allows you to visualize median age by Census tract in a state of your choice."),
    selectInput("state", "Select a state to map", choices = state.name,
                selected = "Delaware"),
    width = 300
  ), 
  card(
    leafletOutput("map")
  )
)

server <- function(input, output) {
  state_data <- reactive({
    get_decennial(
      geography = "tract",
      variables = "P13_001N",
      state = input$state,
      sumfile = "dhc",
      geometry = TRUE
    )
  })
  
  output$map <- renderLeaflet({
    leaflet() |> 
      addTiles() |> 
      addPolygons(
        data = state_data(),
        label = ~value
      )
  })
}

shinyApp(ui, server)