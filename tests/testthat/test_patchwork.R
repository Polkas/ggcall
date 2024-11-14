test_that("patchwork + operator", {
  p1 <- ggplot(mtcars) +
    geom_point(aes(mpg, disp))
  p2 <- ggplot(mtcars) +
    geom_boxplot(aes(gear, disp, group = gear))
  p3 <- ggplot(mtcars) +
    geom_bar(aes(gear)) +
    facet_wrap(~cyl)
  p4 <- ggplot(mtcars) +
    geom_bar(aes(carb))
  plot <- ggcall(p1 + p2 + p3 + plot_layout(ncol = 1))
  deplot <- backports:::deparse1(plot)
  expect_identical(
    deplot,
    backports:::deparse1(
      quote(ggplot(mtcars) +
        geom_point(aes(mpg, disp)) +
        (ggplot(mtcars) +
          geom_boxplot(aes(gear, disp, group = gear))) +
        (ggplot(mtcars) +
          geom_bar(aes(gear)) +
          facet_wrap(~cyl)) +
        plot_layout(ncol = 1))
    )
  )
  expect_true(is.ggplot(eval_ggcall(plot)))

  plot <- ggcall(p1 / p2 - p3)
  deplot <- backports:::deparse1(plot)
  expect_identical(
    deplot,
    backports:::deparse1(
      quote((ggplot(mtcars) + geom_point(aes(mpg, disp)))/(ggplot(mtcars) +
                  geom_boxplot(aes(gear, disp, group = gear))) - (ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl))
      )
    )
  )
  expect_true(is.ggplot(eval_ggcall(plot)))
})
