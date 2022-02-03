library(shiny)

server <- function(input, output, session) {
  rv <- reactiveValues()
  rv$displaying_answer <- FALSE

  output$flashcard_csv_select <- renderUI({
    full_paths <- list.files(
      "flashcard_csvs",
      pattern = ".*\\.csv",
      recursive = TRUE,
      full.names = TRUE
    )

    base_names <- basename(full_paths)
    base_names <- gsub(".csv", "", base_names, fixed = TRUE)

    names(full_paths) <- base_names

    selectInput(
      inputId = "selected_csv",
      label = "Select flashcard set",
      choices = full_paths
    )
  })

  selected_df <- reactive({
    req(input$selected_csv)
    read.csv(input$selected_csv)
  })

  rand_row <- eventReactive(c(input$next_card_btn, input$selected_csv),
    {
      req(selected_df())
      i <- sample(1:nrow(selected_df()), size = 1)
      rv$displaying_answer <- FALSE
      selected_df()[i, ]
    },
    ignoreNULL = FALSE
  )

  output$selected_image <- renderImage(
    {
      req(rand_row())
      img_path <- rand_row()$image_path
      list(
        src = file.path(".", img_path),
        contentType = "image/jpg",
        width = 200,
        height = 200
      )
    },
    deleteFile = FALSE
  )

  observeEvent(input$show_answer_btn, {
    rv$displaying_answer <- TRUE
  })

  output$displayed_answer <- renderText({
    req(rv$displaying_answer)
    rand_row()$answer
  })

  output$flashcard <- renderUI({
    wellPanel(
      imageOutput("selected_image", width = 200, height = 220),
      actionButton("show_answer_btn", "Show Answer"),
      actionButton("next_card_btn", "Next"),
      hr(),
      textOutput("displayed_answer")
    )
  })
}
