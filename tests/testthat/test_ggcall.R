test_that("custom ggplot function initializes history", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg))
  expect_s3_class(p, "ggcall")
  expect_type(attr(p, "ggcall"), "list")
  expect_length(attr(p, "ggcall"), 1)
  expect_true(inherits(attr(p, "ggcall_env"), "environment"))
  expect_true(inherits(attr(p, "ggcall_env_last"), "environment"))
})

test_that("custom '+' operator appends history", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg))
  p <- p + geom_point()
  expect_length(attr(p, "ggcall"), 2)
})

func <- function(x, y) {
  ggplot(mtcars, aes(x = !!as.name(x), y = !!as.name(y))) +
    geom_point(alpha = 0.4) +
    facet_grid(~gear) +
    theme(axis.title.x = element_blank())
}

funy <- function() {
  x <- "wt"
  y <- "mpg"
  func(x, y)
}

test_that("ggcall returns correct class", {
  plot_call <- ggcall(funy())
  expect_true(inherits(plot_call, "ggcall_code"))
  expect_true(inherits(attr(plot_call, "ggcall_env"), "environment"))
})

test_that("ggcall incorrect input", {
  expect_error(ggcall(1), "inherits")
  expect_error(ggcall("a"), "inherits")
})

test_that("ggcall returns correct call", {
  plot_call1 <- ggcall(func("wt", "mpg"))
  plot_call2 <- ggcall(funy())
  testthat::expect_identical(backports:::deparse1(plot_call1), backports:::deparse1(plot_call2))
})

