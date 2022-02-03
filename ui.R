library(shiny)

ui <- fluidPage(
  fluidRow(
    column(
      width = 6, offset = 3, align = "center",
      uiOutput("flashcard_csv_select"),
      uiOutput("flashcard")
    )
  )
)
