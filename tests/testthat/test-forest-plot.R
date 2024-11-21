test_that("forest_plot works with valid input", {
  df <- data.frame(
    Treatment = c("Treatment A", "Treatment B", "Treatment C"),
    Estimate = c(0.2, 0.5, -0.1),
    CI_lower = c(0.1, 0.3, -0.3),
    CI_upper = c(0.3, 0.7, 0.1)
  )

  plot <- forest_plot(df, "Estimate", "CI_lower", "CI_upper", "Treatment")

  expect_s3_class(plot, "ggplot")

  expect_equal(plot$labels$x, "Estimate")
  expect_equal(plot$labels$title, "Forest Plot")

  expected_labels <- unique(df$Treatment)
  actual_labels <- ggplot_build(plot)$layout$panel_params[[1]]$y$get_labels()
  expect_equal(actual_labels, expected_labels)
})

test_that("forest_plot handles missing columns appropriately", {
  df_missing <- data.frame(
    Treatment = c("Treatment A", "Treatment B", "Treatment C"),
    Estimate = c(0.2, 0.5, -0.1)
  )

  expect_error(
    forest_plot(df_missing, "Estimate", "CI_lower", "CI_upper", "Treatment"),
    "The following required columns are missing in 'data': CI_lower, CI_upper"
  )
})

test_that("forest_plot works with custom axis labels and title", {
  df <- data.frame(
    Variable = c("Var1", "Var2", "Var3"),
    Est = c(1.2, 0.8, 1.5),
    Lower = c(0.9, 0.5, 1.1),
    Upper = c(1.5, 1.1, 1.9)
  )

  plot <- forest_plot(
    df,
    estimate_col = "Est",
    ci_lower_col = "Lower",
    ci_upper_col = "Upper",
    label_col = "Variable",
    xlab = "Odds Ratio",
    title = "Custom Forest Plot"
  )

  expect_s3_class(plot, "ggplot")

  expect_equal(plot$labels$x, "Odds Ratio")
  expect_equal(plot$labels$title, "Custom Forest Plot")
})

test_that("forest_plot handles non-numeric data gracefully", {
  df_non_numeric <- data.frame(
    Treatment = c("Treatment A", "Treatment B", "Treatment C"),
    Estimate = c("0.2", "0.5", "-0.1"), # Estimates as strings
    CI_lower = c(0.1, 0.3, -0.3),
    CI_upper = c(0.3, 0.7, 0.1)
  )

  df_non_numeric$Estimate <- as.character(df_non_numeric$Estimate)

  expect_error(
    forest_plot(df_non_numeric, "Estimate", "CI_lower", "CI_upper", "Treatment"),
    "must be numeric"
  )
})

test_that("forest_plot can handle data with additional irrelevant columns", {
  df_extra <- data.frame(
    Treatment = c("Treatment A", "Treatment B", "Treatment C"),
    Estimate = c(0.2, 0.5, -0.1),
    CI_lower = c(0.1, 0.3, -0.3),
    CI_upper = c(0.3, 0.7, 0.1),
    Extra1 = c("A", "B", "C"),
    Extra2 = 1:3
  )

  plot <- forest_plot(df_extra, "Estimate", "CI_lower", "CI_upper", "Treatment")

  expect_s3_class(plot, "ggplot")
})

test_that("forest_plot ggcall", {
  df_extra <- data.frame(
    Treatment = c("Treatment A", "Treatment B", "Treatment C"),
    Estimate = c(0.2, 0.5, -0.1),
    CI_lower = c(0.1, 0.3, -0.3),
    CI_upper = c(0.3, 0.7, 0.1),
    Extra1 = c("A", "B", "C"),
    Extra2 = 1:3
  )

  plot <- forest_plot(df_extra, "Estimate", "CI_lower", "CI_upper", "Treatment")
  expect_s3_class(plot, "ggcall")
  call_plot <- ggcall(plot)
  expect_s3_class(call_plot, "ggcall_code")
  expect_s3_class(eval_ggcall(call_plot), "ggplot")
  real <- paste(deparse(call_plot), collapse = "\n")
  expected <- paste(
    deparse(
      quote(
        ggplot(forest_data, aes(x = .data[[estimate_col]], y = .data[[label_col]])) +
          geom_point(size = 3) +
          geom_errorbarh(aes(xmin = .data[[ci_lower_col]], xmax = .data[[ci_upper_col]]), height = 0.2) +
          labs(x = xlab, y = "", title = forest_title) +
          theme_minimal() +
          theme(axis.text.y = element_text(size = 10), plot.title = element_text(hjust = 0.5, face = "bold"))
      )
    ),
    collapse = "\n"
  )
  expect_identical(
    real,
    expected
  )
})
