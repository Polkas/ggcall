#' @title General Barbell Plot Function
#' @description Creates a barbell plot from a data frame containing two sets of values to compare across categories.
#' @param barbell_data A data frame containing the data for the barbell plot.
#' @param category_col The name of the column containing the category labels (as a string).
#' @param value1_col The name of the first value column to compare (as a string).
#' @param value2_col The name of the second value column to compare (as a string).
#' @param group_labels A character vector of length 2 providing labels for the two values. Defaults to `c("Value 1", "Value 2")`.
#' @param xlab The label for the x-axis. Defaults to "Value".
#' @param title The title of the plot. Defaults to "Barbell Plot".
#' @return A ggplot object representing the barbell plot.
#' @examples
#' # Example data
#' df <- data.frame(
#'   Category = c("A", "B", "C", "D"),
#'   Before = c(3.5, 4.2, 2.8, 5.1),
#'   After = c(4.0, 4.5, 3.1, 5.5)
#' )
#'
#' # Create the barbell plot
#' barbell_plot(df, "Category", "Before", "After", group_labels = c("Before", "After"))
#' @export
barbell_plot <- function(barbell_data, category_col, value1_col, value2_col,
                         group_labels = c("Value 1", "Value 2"),
                         xlab = "Value", title = "Barbell Plot") {
  required_cols <- c(category_col, value1_col, value2_col)
  missing_cols <- setdiff(required_cols, names(barbell_data))
  if (length(missing_cols) > 0) {
    stop("The following required columns are missing in 'data': ", paste(missing_cols, collapse = ", "))
  }

  numeric_cols <- c(value1_col, value2_col)
  for (col in numeric_cols) {
    if (!is.numeric(barbell_data[[col]])) {
      stop("Column '", col, "' must be numeric.")
    }
  }

  if (length(group_labels) != 2) {
    stop("Parameter 'group_labels' must be a character vector of length 2.")
  }

  data_long <- data.frame(
    Category = rep(barbell_data[[category_col]], 2),
    Value = c(barbell_data[[value1_col]], barbell_data[[value2_col]]),
    Group = rep(group_labels, each = nrow(barbell_data))
  )

  data_long$Category <- factor(data_long$Category, levels = unique(barbell_data[[category_col]]))

  barbell_title <- title

  ggplot(data_long, aes(x = .data[["Value"]], y = .data[["Category"]], group = .data[["Category"]])) +
    geom_line(aes(group = .data[["Category"]]), color = "gray70", linewidth = 1) +
    geom_point(aes(color = .data[["Group"]]), size = 4) +
    scale_color_manual(values = c("#00BFC4", "#F8766D"), name = "") +
    labs(x = xlab, y = "", title = barbell_title) +
    theme_minimal() +
    theme(
      axis.text.y = element_text(size = 10),
      plot.title = element_text(hjust = 0.5, face = "bold"),
      legend.position = "bottom"
    )
}
