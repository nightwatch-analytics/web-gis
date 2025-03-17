library(shiny)
library(bslib)

# Basic app template
ui <- page_sidebar(

)

server <- function(input, output) {
  
}

shinyApp(ui, server)

# Theming the app with Bootswatch
ui <- page_sidebar(
  title = "My first app",
)

server <- function(input, output) {
 
}

run_with_themer(shinyApp(ui, server))

# Choosing a theme
ui <- page_sidebar(
  title = "My first app",
  theme = bs_theme(bootswatch = "yeti")
)

server <- function(input, output) {

}

shinyApp(ui, server)