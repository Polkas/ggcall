# nolint start
# styler: off

p1 <- ggplot(mtcars) + geom_point(aes(mpg, disp))
p2 <- ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear))
p3 <- ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)
p4 <- ggplot(mtcars) + geom_bar(aes(carb))

test_that("patchwork + operator pure", {
  expect_error(p1 + p2 + p3, NA)
  gcall <- ggcall(p1 + p2 + p3)
  decall <- paste(deparse(gcall), collapse = "\n")
  expect_identical(
    decall,
    paste(
      deparse(
        quote(
          ggplot(mtcars) + geom_point(aes(mpg, disp)) +
            (ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear))) +
            (ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl))
        )
      ),
      collapse = "\n"
    )
  )
  expect_true(is.ggplot(eval_ggcall(gcall)))
})

test_that("patchwork operators - direct pure", {
  expect_error(p1 | p2 - p3 * p4 + p1 & p2 | p3, NA)
  gcall <- ggcall(p1 | p2 - p3 * p4 + p1 & p2 | p3)
  decall <- paste(deparse(gcall), collapse = "\n")
  expect_identical(
    decall,
    paste(
      deparse(
        quote(
          ggplot(mtcars) + geom_point(aes(mpg, disp)) |
            ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear)) -
            (ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)) *
            (ggplot(mtcars) + geom_bar(aes(carb))) +
            (ggplot(mtcars) + geom_point(aes(mpg, disp))) &
            ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear)) |
            ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)
        )
      ),
      collapse = "\n"
    )
  )
  expect_true(is.ggplot(eval_ggcall(gcall)))
})

library(patchwork)

test_that("patchwork + operator with patchwork", {
  expect_error(p1 + p2 + p3 + plot_layout(ncol = 1), NA)
  gcall <- ggcall(p1 + p2 + p3 + plot_layout(ncol = 1))
  decall <- paste(deparse(gcall), collapse = "\n")
  expect_identical(
    decall,
    paste(
      deparse(
        quote(
          ggplot(mtcars) + geom_point(aes(mpg, disp)) +
            (ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear))) +
            (ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)) +
            plot_layout(ncol = 1)
        )
      ),
      collapse = "\n"
    )
  )
  expect_true(is.ggplot(eval_ggcall(gcall)))
})

test_that("patchwork operators - direct", {
  expect_error(p1 | p2 - p3 * p4 + p1 & p2 | p3, NA)
  gcall <- ggcall(p1 | p2 - p3 * p4 + p1 & p2 | p3)
  decall <- paste(deparse(gcall), collapse = "\n")
  expect_identical(
    decall,
    paste(
      deparse(
        quote(
          ggplot(mtcars) + geom_point(aes(mpg, disp)) |
            ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear)) -
            (ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)) *
            (ggplot(mtcars) + geom_bar(aes(carb))) +
            (ggplot(mtcars) + geom_point(aes(mpg, disp))) &
            ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear)) |
            ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)
        )
      ),
      collapse = "\n"
    )
  )
  expect_true(is.ggplot(eval_ggcall(gcall)))
})


test_that("patchwork operators - internal", {
  funy <- function() {
    p1 <- ggplot(mtcars) + geom_point(aes(mpg, disp))
    p2 <- ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear))
    p3 <- ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)
    p4 <- ggplot(mtcars) + geom_bar(aes(carb))

    (p1 | p2 - p3 * p4 + p1 & p2 | p3 / p1)
  }

  gcall <- ggcall(funy())

  decall <- paste(deparse(gcall), collapse = "\n")

  expect_identical(
    decall,
    paste(
      deparse(
        quote(
          ggplot(mtcars) + geom_point(aes(mpg, disp)) |
            ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear)) -
            (ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)) *
            (ggplot(mtcars) + geom_bar(aes(carb))) +
            (ggplot(mtcars) + geom_point(aes(mpg, disp))) &
            ggplot(mtcars) + geom_boxplot(aes(gear, disp, group = gear)) |
            (ggplot(mtcars) + geom_bar(aes(gear)) + facet_wrap(~cyl)) /
            (ggplot(mtcars) + geom_point(aes(mpg, disp)))
        )
      ),
      collapse = "\n"
    )
  )
  expect_true(is.ggplot(eval_ggcall(gcall)))
})

# styler: on
# nolint end
