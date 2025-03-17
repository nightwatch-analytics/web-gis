library(shiny)
library(bslib)
library(leaflet)
library(tidycensus)
options(tigris_use_cache = TRUE)
library(glue)

ui <- page_sidebar(
  title = "Median age explorer",
  sidebar = sidebar(
    p("This app allows you to visualize median age by Census tract in a state of your choice."),
    selectInput("state", "Select a state to map", choices = state.name,
                selected = "Delaware"),
    textOutput("tract_text"),
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
    
    my_state <- state_data()
    
    pal <- colorNumeric("viridis", my_state$value)
    
    leaflet() |> 
      addProviderTiles(providers$CartoDB.Positron) |> 
      addPolygons(
        data = my_state,
        color = ~pal(value),
        weight = 0.5,
        fillOpacity = 0.5,
        smoothFactor = 0.2,
        label = ~value, 
        layerId = ~GEOID
      ) |> 
      addLegend(
        position = "topright",
        pal = pal,
        values = my_state$value,
        title = "Median age<br>2020 US Census"
      )
  })
  
  clicked_tract <- reactive({
    input$map_shape_click$id
  }) |> 
    bindEvent(input$map_shape_click, ignoreNULL = TRUE)
  
  output$tract_text <- renderPrint({
    glue("You clicked on Census tract {clicked_tract()}")
  })
  
}

shinyApp(ui, server)