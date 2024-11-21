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
  expect_true(grepl("data <-", paste(deparse(result_call), collapse = "\n")))
  expect_true(grepl("x <-", paste(deparse(result_call), collapse = "\n")))
  expect_true(grepl("y <-", paste(deparse(result_call), collapse = "\n")))
  expect_true(
    grepl(
      'data <- ggcall_env\\(plot_call\\)\\[\\[\\"data\\"\\]\\]',
      paste(deparse(result_call), collapse = "\n")
    )
  )
  expect_true(grepl('x <- \\"wt\\"', paste(deparse(result_call), collapse = "\n")))
  expect_true(grepl('y <- \\"mpg\\"', paste(deparse(result_call), collapse = "\n")))
  expect_true(grepl("ggplot\\(data", paste(deparse(result_call), collapse = "\n")))
  expect_silent(eval(result_call))
})


test_that("ggcall_add_assignments incorrectly adds assignments", {
  result_call <- ggcall_add_assignments(plot_call, vars = "x")
  expect_true(grepl("x <-", paste(deparse(result_call), collapse = "\n")))
  expect_false(grepl("data <-", paste(deparse(result_call), collapse = "\n")))
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

test_that("ggcall_add_assignments empty vars arg", {
  gcall <- ggcall(ggplot())
  gcall_assignments <- ggcall_add_assignments(gcall, character(0))
  expect_s3_class(gcall_assignments, "ggcall_code")
  expect_type(gcall_assignments, "language")
})
