func <- function(data, x, y, bool = TRUE) {
  # layers have to be added with +
  gg <- ggplot(data, aes(x = !!as.name(x), y = !!as.name(y))) +
    geom_point(alpha = 0.4) +
    facet_grid(~gear)

  if (bool) {
    gg <- gg + theme(axis.title.x = element_blank())
  }

  func_internal <- function(gg) {
    gg + labs(x = "custom xlab", aa)
  }

  aa <- airquality$Ozone

  func_internal(gg)
}

plot_call <- ggcall(func(mtcars, "wt", "mpg"))

test_that("ggcall_add_assignments correctly adds assignments", {
  result_call <- ggcall_add_assignments(plot_call)

  expect_true(inherits(result_call, "ggcall_code"))
  expect_true(grepl("data <-", backports:::deparse1(result_call)))
  expect_true(grepl("x <-", backports:::deparse1(result_call)))
  expect_true(grepl("y <-", backports:::deparse1(result_call)))
  expect_true(grepl('data <- ggcall_env\\(plot_call\\)\\[\\[\\"data\\"\\]\\]', backports:::deparse1(result_call)))
  expect_true(grepl('x <- \\"wt\\"', backports:::deparse1(result_call)))
  expect_true(grepl('y <- \\"mpg\\"', backports:::deparse1(result_call)))
  expect_true(grepl("ggplot\\(data", backports:::deparse1(result_call)))
  expect_silent(eval(result_call))
})


test_that("ggcall_add_assignments incorrectly adds assignments", {
  result_call <- ggcall_add_assignments(plot_call, vars = "x")
  expect_true(grepl("x <-", backports:::deparse1(result_call)))
  expect_false(grepl("data <-", backports:::deparse1(result_call)))
  expect_error(eval(result_call))
})


test_that("ggcall_add_assignments wrong input type", {
  expect_error(ggcall_add_assignments(1), "inherits")
  expect_error(ggcall_add_assignments(ggplot()), "inherits")
  expect_error(ggcall_add_assignments(ggplot(), vars = 2), "inherits")
})

test_that("ggcall_add_assignments worng direct ggcall", {
  expect_error(ggcall_add_assignments(ggcall(ggplot())), "symbol")
})
