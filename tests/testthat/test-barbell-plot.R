test_that("barbell_plot works with valid input", {
  df <- data.frame(
    Category = c("A", "B", "C", "D"),
    Before = c(3.5, 4.2, 2.8, 5.1),
    After = c(4.0, 4.5, 3.1, 5.5)
  )

  plot <- barbell_plot(df, "Category", "Before", "After", group_labels = c("Before", "After"))

  expect_s3_class(plot, "ggplot")

  expect_equal(plot$labels$x, "Value")
  expect_equal(plot$labels$title, "Barbell Plot")

  expected_categories <- unique(df$Category)
  actual_categories <- levels(plot$data$Category)
  expect_equal(actual_categories, expected_categories)
})

test_that("barbell_plot handles missing columns appropriately", {
  df_missing <- data.frame(
    Category = c("A", "B", "C", "D"),
    Before = c(3.5, 4.2, 2.8, 5.1)
  )

  expect_error(
    barbell_plot(df_missing, "Category", "Before", "After"),
    "The following required columns are missing in 'data': After"
  )
})

test_that("barbell_plot checks for numeric value columns", {
  df_non_numeric <- data.frame(
    Category = c("A", "B", "C", "D"),
    Before = c("3.5", "4.2", "2.8", "5.1"), # Non-numeric
    After = c(4.0, 4.5, 3.1, 5.5)
  )

  expect_error(
    barbell_plot(df_non_numeric, "Category", "Before", "After"),
    "Column 'Before' must be numeric."
  )
})

test_that("barbell_plot checks group_labels length", {
  df <- data.frame(
    Category = c("A", "B", "C", "D"),
    Value1 = c(3.5, 4.2, 2.8, 5.1),
    Value2 = c(4.0, 4.5, 3.1, 5.5)
  )

  expect_error(
    barbell_plot(df, "Category", "Value1", "Value2", group_labels = c("Group1")),
    "Parameter 'group_labels' must be a character vector of length 2."
  )
})

test_that("barbell_plot works with custom axis labels and title", {
  df <- data.frame(
    Item = c("Item1", "Item2", "Item3"),
    Baseline = c(10, 15, 20),
    FollowUp = c(12, 14, 22)
  )

  plot <- barbell_plot(
    df,
    category_col = "Item",
    value1_col = "Baseline",
    value2_col = "FollowUp",
    group_labels = c("Baseline", "Follow-Up"),
    xlab = "Score",
    title = "Comparison Over Time"
  )

  expect_s3_class(plot, "ggplot")

  expect_equal(plot$labels$x, "Score")
  expect_equal(plot$labels$title, "Comparison Over Time")
})


test_that("forest_plot ggcall", {
  df <- data.frame(
    Item = c("Item1", "Item2", "Item3"),
    Baseline = c(10, 15, 20),
    FollowUp = c(12, 14, 22)
  )

  plot <- barbell_plot(
    df,
    category_col = "Item",
    value1_col = "Baseline",
    value2_col = "FollowUp",
    group_labels = c("Baseline", "Follow-Up"),
    xlab = "Score",
    title = "Comparison Over Time"
  )

  expect_s3_class(plot, "ggcall")
  call_plot <- ggcall(plot)
  expect_s3_class(call_plot, "ggcall_code")
  expect_s3_class(eval_ggcall(call_plot), "ggplot")
  real <- paste(deparse(call_plot), collapse = "\n")
  expected <- paste(
    deparse(
      quote(
        ggplot(data_long, aes(x = .data[["Value"]], y = .data[["Category"]], group = .data[["Category"]])) +
          geom_line(aes(group = .data[["Category"]]), color = "gray70", linewidth = 1) +
          geom_point(aes(color = .data[["Group"]]), size = 4) +
          scale_color_manual(values = c("#00BFC4", "#F8766D"), name = "") +
          labs(x = xlab, y = "", title = barbell_title) +
          theme_minimal() +
          theme(
            axis.text.y = element_text(size = 10), plot.title = element_text(hjust = 0.5, face = "bold"),
            legend.position = "bottom"
          )
      )
    ),
    collapse = "\n"
  )
  expect_identical(
    real,
    expected
  )
})
