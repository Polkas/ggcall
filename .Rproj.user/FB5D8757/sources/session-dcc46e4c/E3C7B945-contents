test_that("custom ggplot function initializes history", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg))
  expect_true("ggplot_history" %in% class(p))
  expect_type(attr(p, "plot_history"), "list")
  expect_length(attr(p, "plot_history"), 1)
})

test_that("custom '+' operator appends history", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg))
  p <- p + geom_point()
  expect_length(attr(p, "plot_history"), 2)
})

func <- function(x, y) {
  ggplot(mtcars, aes(x=!!as.name(x), y=!!as.name(y))) +
    geom_point(alpha = 0.4) +
    facet_grid(~gear) +
    theme(axis.title.x = element_blank())
}

funy <- function() {
  x <- "wt"
  y <- "mpg"
  func(x, y)
}

test_that("get_ggplot_code returns correct history", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()
  plot_code <- get_ggplot_code(p, call = FALSE)
  expect_true(inherits(plot_code, "ggplot_history_code"))
  expect_length(plot_code, 2)

  plot_code1 <- get_ggplot_code(func("wt", "mpg"))
  plot_code2 <- get_ggplot_code(funy())
  testthat::expect_identical(deparse1(plot_code1), deparse1(plot_code2))
})

test_that("eval_ggplot_code reproduces the plot", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()
  plot_code <- get_ggplot_code(p)
  reconstructed_plot <- eval_ggplot_code(plot_code)
  expect_true(inherits(reconstructed_plot, "ggplot"))
  expect_length(attr(reconstructed_plot, "plot_history"), 2)

  plot_code1 <- get_ggplot_code(func("wt", "mpg"))
  plot_code2 <- get_ggplot_code(funy())

  testthat::expect_identical(c("x", "y"),
                             ls(attr(plot_code2, "plot_history_env")))

  testthat::expect_identical(ls(attr(plot_code1, "plot_history_env")),
                             ls(attr(plot_code2, "plot_history_env")))

  path1 <- tempfile(fileext = ".png")
  png(path1, width = 400, height = 400)
  print(eval_ggplot_code(plot_code1))
  dev.off()

  path2 <- tempfile(fileext = ".png")
  png(path2, width = 400, height = 400)
  print(eval_ggplot_code(plot_code2))
  dev.off()

  testthat::expect_snapshot_file(path1, "ggplot1.png")
  testthat::expect_snapshot_file(path2, "ggplot2.png")
})
