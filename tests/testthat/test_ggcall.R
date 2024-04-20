test_that("custom ggplot function initializes history", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg))
  expect_s3_class(p, "ggcall")
  expect_type(attr(p, "ggcall"), "list")
  expect_length(attr(p, "ggcall"), 1)
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

func_internal <- function(x, y) {
  gg <- ggplot(mtcars, aes(x = !!as.name(x), y = !!as.name(y)))

  fun <- function() {
    a <- 0.4
    gg +
      geom_point(alpha = a) +
      facet_grid(~gear) +
      theme(axis.title.x = element_blank())
  }

  fun()
}

func_internal2 <- function(x, y) {
  gg <- ggplot(mtcars, aes(x = !!as.name(x), y = !!as.name(y)))

  fun <- function() {
    a <- 0.4
    ggg <- gg +
      geom_point(alpha = a) +
      facet_grid(~gear)
    funn <- function() {
      aa <- element_blank()
      ggg +
        theme(axis.title.x = aa)
    }
    funn()
  }
  fun()
}

func_internal3 <- function(x, y) {
  gg <- ggplot(mtcars, aes(x = !!as.name(x), y = !!as.name(y)))
  fun <- function() {
    aa <- 0.4
    gg <- gg +
      geom_point(alpha = aa) +
      facet_grid(~gear)
    funn <- function() {
      aa <- element_blank()
      gg +
        theme(axis.title.x = aa)
    }
    funn()
  }
  fun()
}

test_that("ggcall returns correct call", {
  plot_call1 <- ggcall(func("wt", "mpg"))
  plot_call2 <- ggcall(funy())
  testthat::expect_identical(backports:::deparse1(plot_call1), backports:::deparse1(plot_call2))
})

test_that("eval_ggcall reproduces the plot", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point()
  plot_call <- ggcall(p)
  reconstructed_plot <- eval_ggcall(plot_call)
  expect_true(inherits(reconstructed_plot, "ggplot"))
  expect_length(attr(reconstructed_plot, "ggcall"), 2)

  original_plot <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point(alpha = 0.4) +
    facet_grid(~gear) +
    theme(axis.title.x = element_blank())
  plot_call1 <- ggcall(func("wt", "mpg"))
  plot_call2 <- ggcall(funy())
  plot_call3 <- ggcall(func_internal("wt", "mpg"))
  plot_call4 <- ggcall(func_internal2("wt", "mpg"))
  plot_call5 <- ggcall(func_internal3("wt", "mpg"))

  testthat::expect_setequal(
    c("x", "y"),
    ls(attr(plot_call2, "ggcall_env"))
  )

  testthat::expect_identical(
    ls(attr(plot_call1, "ggcall_env")),
    ls(attr(plot_call2, "ggcall_env"))
  )

  testthat::expect_setequal(
    c("x", "y", "a", "fun", "gg"),
    ls(attr(plot_call3, "ggcall_env"))
  )

  testthat::expect_true(all.equal(plot_call1, plot_call2))
  testthat::expect_false(isTRUE(all.equal(plot_call1, plot_call3)))

  reconstructed_plot1 <- eval_ggcall(plot_call1)
  reconstructed_plot2 <- eval_ggcall(plot_call2)
  reconstructed_plot3 <- eval_ggcall(plot_call3)
  reconstructed_plot4 <- eval_ggcall(plot_call4)
  testthat::expect_error(print(eval_ggcall(plot_call5)), "theme element must be a")

  render_plot <- function(plot) {
    tempf <- tempfile(fileext = ".png")
    grDevices::png(filename = tempf, width = 400, height = 400)
    print(plot)
    grDevices::dev.off()
    tempf
  }

  testthat::compare_file_binary(render_plot(reconstructed_plot1), render_plot(original_plot))
  testthat::compare_file_binary(render_plot(reconstructed_plot1), render_plot(reconstructed_plot2))
  testthat::compare_file_binary(render_plot(reconstructed_plot1), render_plot(reconstructed_plot3))
  testthat::compare_file_binary(render_plot(reconstructed_plot1), render_plot(reconstructed_plot4))
})

testthat::test_that("eval_ggcall works with ellipsis", {
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point()
  plot_call <- ggcall(p)
  mtcars2 <- mtcars[1:10, ]
  new_plot <- eval_ggcall(plot_call, mtcars = mtcars2)
  expect_identical(nrow(new_plot$data), 10L)
  expect_true(inherits(new_plot, "ggplot"))
  expect_length(attr(new_plot, "ggcall"), 2)
})
