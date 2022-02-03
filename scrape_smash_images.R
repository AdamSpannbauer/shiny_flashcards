library(httr)
library(rvest)


URL <- "https://supersmashbros.fandom.com/wiki/Super_Smash_Bros._Melee"
OUT_IMAGE_DIR <- 'images'
OUT_CSV <- 'flashcard_csvs/ssbm.csv'

parse_table <- function(table_node) {
  df <- html_table(table_node)
  srcs <- html_nodes(table_node, "img") %>%
    html_attr("data-src")

  # 2 images per row. i only care about first
  idxs <- seq(1, length(srcs), 2)
  srcs <- srcs[idxs]
  df$image_url <- srcs
  df$answer <- df$Name
  df <- df[, c("image_url", "answer")]

  df
}

html_content <- content(GET(URL))
tables <- html_nodes(html_content, "table")

# bad hard coding
table_1 <- tables[[2]]
table_2 <- tables[[3]]

# parse and combine tables
char_df_1 <- parse_table(table_1)
char_df_2 <- parse_table(table_2)
char_df <- rbind(char_df_1, char_df_2)
char_df$image_path <- NA_character_

# download images
for (i in 1:nrow(char_df)) {
  out_name <- paste0(char_df$answer[i], '.png')
  out_path <- file.path(OUT_IMAGE_DIR, out_name)
  char_df$image_path[i] <- out_path
  download.file(char_df$image_url[i], out_path)
}

write.csv(char_df, OUT_CSV, row.names = FALSE)
