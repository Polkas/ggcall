# nolint start
# styler: off

p1 <- ggplot(mtcars) + geom_point(aes(mpg, disp))
p2 <- ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear))
p3 <- ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)
p4 <- ggplot(mtcars) + geom_bar(aes(carb))

test_that("lack of patchwork", {
  expect_error(p1 + p2, "patchwork package has to be library/require first")
})

library(patchwork)

test_that("patchwork + operator", {
  expect_error(p1 + p2 + p3 + plot_layout(ncol = 1), NA)
  plot <- ggcall(p1 + p2 + p3 + plot_layout(ncol = 1))
  deplot <- backports:::deparse1(plot)
  expect_identical(
    deplot,
    backports:::deparse1(
      quote(
        ggplot(mtcars) + geom_point(aes(mpg, disp)) +
        (ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear))) +
        (ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)) +
        plot_layout(ncol = 1)
      )
    )
  )
  expect_true(is.ggplot(eval_ggcall(plot)))
})

test_that("patchwork operators - direct", {
  expect_error(p1 | p2 - p3 * p4 + p1 & p2 | p3, NA)
  plot <- ggcall(p1 | p2 - p3 * p4 + p1 & p2 | p3)
  deplot <- backports:::deparse1(plot)
  expect_identical(
    deplot,
    backports:::deparse1(
      quote(
        ggplot(mtcars) + geom_point(aes(mpg, disp)) |
        ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear)) -
        (ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)) *
        (ggplot(mtcars) + geom_bar(aes(carb))) +
        (ggplot(mtcars) + geom_point(aes(mpg, disp))) &
        ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear)) |
        ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)
      )
    )
  )
  expect_true(is.ggplot(eval_ggcall(plot)))
})


test_that("patchwork operators - internal", {
  funy <- function() {
    p1 <- ggplot(mtcars) + geom_point(aes(mpg, disp))
    p2 <- ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear))
    p3 <- ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)
    p4 <- ggplot(mtcars) + geom_bar(aes(carb))

    (p1 | p2 - p3 * p4 + p1 & p2 | p3)
  }

  plot <- ggcall(funy())

  deplot <- backports:::deparse1(plot)

  expect_identical(
    deplot,
    backports:::deparse1(
      quote(
        ggplot(mtcars) + geom_point(aes(mpg, disp)) |
        ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear)) -
        (ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)) *
        (ggplot(mtcars) + geom_bar(aes(carb))) +
        (ggplot(mtcars) + geom_point(aes(mpg, disp))) &
        ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear)) |
        ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)
      )
    )
  )

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
})

# styler: on
# nolint end
