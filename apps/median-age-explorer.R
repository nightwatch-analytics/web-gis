library(bslib)
library(glue)
library(leaflet)
library(shiny)
library(tidycensus)
library(tidyverse)

options(tigris_use_cache = TRUE)

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
  ),
  card(
    card_header("Click the map to show a chart"),
    plotOutput("chart"), max_height = "250px",
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

  age_profile_data <- reactive({
    age_profile_vars <- glue("DP1_00{str_pad(2:19, 2, 'left', '0')}P")

    get_decennial(
      geography = "tract",
      variables = age_profile_vars,
      state = input$state,
      year = 2020,
      sumfile = "dp"
    ) |>
      filter(GEOID == clicked_tract())
  }) |>
    bindEvent(clicked_tract(), ignoreNULL = TRUE)

  output$tract_text <- renderPrint({
    glue("Selected Census tract: {clicked_tract()}, {input$state}")
  })

  output$chart <- renderPlot({

    age_labels <- c("0-4", "5-9", "10-14", "15-19",
                    "20-24", "25-29", "30-34", "35-39",
                    "40-44", "45-49", "50-54", "55-59",
                    "60-64", "65-69", "70-74", "75-79",
                    "80-84", "85+")

    ggplot(age_profile_data(), aes(x = variable, y = value)) +
      geom_col(fill = "darkgreen", alpha = 0.8) +
      theme_minimal(base_size = 16) +
      scale_x_discrete(labels = age_labels) +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(
        axis.text.x = element_text(angle = 45)
      ) +
      labs(x = "Age cohort in Census tract",
           y = "Percent")
  })

}

shinyApp(ui, server)