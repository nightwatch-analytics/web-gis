library(shiny)
library(bslib)
library(leaflet)

ui <- page_sidebar(
  title = "Interactive map",
  theme = bs_theme(bootswatch = "yeti"),
  sidebar = sidebar(
    p("Explore this interactive map!")
  ),
  card(
    leafletOutput("map")
  )
)

server <- function(input, output) {
  output$map <- renderLeaflet({
    leaflet() |>
      addTiles()
  })
}

shinyApp(ui, server)