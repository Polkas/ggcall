func <- function(x, y) {
  ggplot(mtcars, aes(x = !!as.name(x), y = !!as.name(y))) +
    geom_point(alpha = 0.4) +
    facet_grid(~gear) +
    theme(axis.title.x = element_blank())
}

test_that("ggcall_env returns an environment", {
  plot_call <- ggcall(func("wt", "mpg"))
  expect_true(inherits(ggcall_env(plot_call), "environment"))
  expect_true(all(c("x", "y") %in% ls(ggcall_env(plot_call))))
  expect_identical(ggcall_env(plot_call)[["x"]], "wt")
  expect_identical(ggcall_env(plot_call)[["y"]], "mpg")
})
