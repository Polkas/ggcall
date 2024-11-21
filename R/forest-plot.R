#' @title Forest Plot Function
#' @description Creates a forest plot from a data frame containing estimates and confidence intervals.
#' @param forest_data A data frame containing the data for the forest plot.
#' @param estimate_col The name of the column containing the point estimates (as a string).
#' @param ci_lower_col The name of the column containing the lower bounds of the confidence intervals (as a string).
#' @param ci_upper_col The name of the column containing the upper bounds of the confidence intervals (as a string).
#' @param label_col The name of the column containing the labels for each estimate (as a string).
#' @param xlab The label for the x-axis. Defaults to "Estimate".
#' @param title The title of the plot. Defaults to "Forest Plot".
#' @return A ggplot object representing the forest plot.
#' @examples
#' # Example data
#' df <- data.frame(
#'   Treatment = c("Treatment A", "Treatment B", "Treatment C"),
#'   Estimate = c(0.2, 0.5, -0.1),
#'   CI_lower = c(0.1, 0.3, -0.3),
#'   CI_upper = c(0.3, 0.7, 0.1)
#' )
#'
#' # Create the forest plot
#' forest_plot(df, "Estimate", "CI_lower", "CI_upper", "Treatment")
#' @export
forest_plot <- function(forest_data, estimate_col, ci_lower_col, ci_upper_col, label_col,
                        xlab = "Estimate", title = "Forest Plot") {
  required_cols <- c(estimate_col, ci_lower_col, ci_upper_col, label_col)
  missing_cols <- setdiff(required_cols, names(forest_data))
  if (length(missing_cols) > 0) {
    stop("The following required columns are missing in 'data': ", paste(missing_cols, collapse = ", "))
  }

  numeric_cols <- c(estimate_col, ci_lower_col, ci_upper_col)
  for (col in numeric_cols) {
    if (!is.numeric(forest_data[[col]])) {
      stop("Column '", col, "' must be numeric.")
    }
  }

  forest_data[[label_col]] <- factor(forest_data[[label_col]], levels = unique(forest_data[[label_col]]))

  forest_title <- title

  ggplot(forest_data, aes(x = .data[[estimate_col]], y = .data[[label_col]])) +
    geom_point(size = 3) +
    geom_errorbarh(aes(xmin = .data[[ci_lower_col]], xmax = .data[[ci_upper_col]]), height = 0.2) +
    labs(x = xlab, y = "", title = forest_title) +
    theme_minimal() +
    theme(
      axis.text.y = element_text(size = 10),
      plot.title = element_text(hjust = 0.5, face = "bold")
    )
}
