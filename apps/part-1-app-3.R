library(shiny)
library(bslib)
library(leaflet)

ui <- page_sidebar(
  title = "Interactive map",
  theme = bs_theme(bootswatch = "yeti"),
  sidebar = sidebar(
    p("Explore this interactive map!"),
    selectInput("basemap",
                label = "Choose a basemap",
                choices = c(
                  OpenStreetMap = providers$OpenStreetMap,
                  "CARTO Positron" = providers$CartoDB.Positron,
                  "CARTO Voyager" = providers$CartoDB.Voyager,
                  "Stadia Toner" = providers$Stadia.StamenToner
                ))
  ),
  card(
    leafletOutput("map")
  )
)

server <- function(input, output) {
  output$map <- renderLeaflet({
    leaflet() |>
      addProviderTiles(provider = input$basemap)
  })
}

shinyApp(ui, server)