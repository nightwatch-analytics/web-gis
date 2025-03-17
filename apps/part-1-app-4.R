library(shiny)
library(bslib)
library(leaflet)
library(mapboxapi)

# This app throws an error:

ui <- page_sidebar(
  title = "Address finder",
  theme = bs_theme(bootswatch = "yeti"),
  sidebar = sidebar(
    selectInput("basemap", "Choose a basemap",
      choices = c(
        OpenStreetMap = providers$OpenStreetMap,
        "CARTO Positron" = providers$CartoDB.Positron,
        "CARTO Voyager" = providers$CartoDB.Voyager,
        "Stadia Toner" = providers$Stadia.StamenToner
      )
    ),
    p("Use the geocoder to find an address!"),
    mapboxGeocoderInput("geocoder",
      placeholder = "Search for an address"
    ),
    width = 300
  ),
  card(
    leafletOutput("map")
  )
)

server <- function(input, output) {
  output$map <- renderLeaflet({
    leaflet() |>
      addProviderTiles(provider = input$basemap) |>
      addMarkers(
        data = geocoder_as_sf(input$geocoder)
      )
  })
}

shinyApp(ui, server)
