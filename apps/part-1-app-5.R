library(shiny)
library(bslib)
library(leaflet)
library(mapboxapi)

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
      addProviderTiles(provider = providers$OpenStreetMap) |>
      setView(
        lng = -96.805,
        lat = 32.793,
        zoom = 12
      )
  })

  observe({
    leafletProxy("map") |>
      clearTiles() |>
      addProviderTiles(provider = input$basemap)
  }) |>
    bindEvent(input$basemap)

  observe({
    xy <- geocoder_as_xy(input$geocoder)

    leafletProxy("map") |>
      clearMarkers() |>
      addMarkers(
        lng = xy[1],
        lat = xy[2]
      ) |>
      flyTo(
        lng = xy[1],
        lat = xy[2],
        zoom = 14
      )
  }) |>
    bindEvent(input$geocoder, ignoreNULL = TRUE)
}

shinyApp(ui, server)
