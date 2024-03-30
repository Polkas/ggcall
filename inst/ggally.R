# ggpairs_add.R

#' Modify a \code{\link{ggmatrix}} object by adding an \pkg{ggplot2} object to all plots
#'
#' This operator allows you to add \pkg{ggplot2} objects to a \code{\link{ggmatrix}} object.
#'
#' If the first object is an object of class \code{\link{ggmatrix}}, you can add
#' the following types of objects, and it will return a modified \pkg{ggplot2}
#' object.
#'
#' \itemize{
######   \item \code{data.frame}: replace current data.frame
######      (must use \code{%+%})
######   \item \code{uneval}: replace current aesthetics
######   \item \code{layer}: add new layer
#'   \item \code{theme}: update plot theme
#'   \item \code{scale}: replace current scale
#'   \item \code{coord}: override current coordinate system
######   \item \code{facet}: override current coordinate faceting
#' }
#'
#' The \code{+} operator completely replaces elements
#' with elements from e2.
#'
#' @param e1 An object of class \code{\link{ggnostic}} or \code{ggplot}
#' @param e2 A component to add to \code{e1}
#'
#' @export
#' @seealso [ggplot2::+.gg] and [ggplot2::theme()]
#' @method + gg
#' @rdname gg-add
#' @examples
#' library(GGally)
#' data(mtcars)
#' gg <- ggcorr(mtcars, method = "everything", label = TRUE)
#' gg_code <- get_ggplot_code(gg)
#' # styler::style_text(deparse1(gg_code))
#' # ls(attr(gg_code, "plot_history_env"))
#' eval_ggplot_code(gg_code)
#' 
#' data(iris)
#' gg <- ggscatmat(iris, color = "Species")
#' gg_code <- get_ggplot_code(gg)
#' # styler::style_text(deparse1(gg_code))
#' # ls(attr(gg_code, "plot_history_env"))
#' eval_ggplot_code(gg_code)
#' 
#' data(tips, package = "reshape")
#' # Not supported for ggmatrix like plots
#' gg <- ggduo(tips, mapping = ggplot2::aes(colour = sex), columnsX = 3:4, columnsY = 1:2)
#' # Will fail
#' # gg_code <- get_ggplot_code(gg)
"+.gg" <- function(e1, e2) {
  if (!is.ggmatrix(e1)) {
    stopifnot(inherits(e1, "ggplot_history"))
    validate_ggplot()
    plot <- utils::getFromNamespace("+.gg", "ggplot2")(e1, e2)

    # Append to the existing history
    if (!is.null(attr(e1, "plot_history"))) {
      history <- attr(e1, "plot_history")
    } else {
      history <- list()
    }
    history <- c(history, list(substitute(e2)))
    attr(plot, "plot_history") <- history

    merge_env <- function(to_env, from_env) {
      for(name in ls(from_env)) {
        assign(name, get(name, envir = from_env), envir = to_env)
      }
      to_env
    }

    if (!identical(parent.frame(), attr(plot, "plot_history_env"))) {
      attr(plot, "plot_history_env") <- merge_env(attr(plot, "plot_history_env"), parent.frame())
    }

    return(plot)
  }

  if (is.null(e1$gg)) {
    e1$gg <- list()
  }
  if (inherits(e2, "labels")) {
    add_labels_to_ggmatrix(e1, e2)
  } else if (is.theme(e2)) {
    add_theme_to_ggmatrix(e1, e2)
  } else if (is.list(e2)) {
    add_list_to_ggmatrix(e1, e2)
  } else if (is.ggproto(e2)) {
    add_to_ggmatrix(e1, e2)
  } else {
    stop(
      "'ggmatrix' does not know how to add objects that do not have class 'theme', 'labels' or 'ggproto'.",
      " Received object with class: '", paste(class(e2), collapse = ", "), "'"
    )
  }
}

# gghistory.R

#' Enhanced `ggplot` Function with History Tracking
#'
#' Overrides the default `ggplot` function from the ggplot2 package, adding the
#' capability to track the history of plot construction. 
#' This function initializes a history attribute in the `ggplot` object.
#'
#' @param ... Arguments passed to the original ggplot function from ggplot2.
#'
#' @return A ggplot object of class 'ggplot_history', with an additional
#' attribute 'plot_history' that stores the history of plot construction.
#'
#' @seealso \code{\link[ggplot2]{ggplot}}
#' @importFrom ggplot2 ggplot
#' @examples
#' p <- ggplot(mtcars, aes(x=wt, y=mpg))
#' # the + function has to come from gghistory package
#' attr(p + geom_point(), "plot_history")
#'
#' @export
#'
ggplot <- function(...) {
  validate_ggplot()
  plot <- ggplot2::ggplot(...)

  # Initialize the history with the first call
  history <- list(match.call())
  attr(plot, "plot_history") <- history
  attr(plot, "plot_history_env") <- parent.frame()
  class(plot) <- c("ggplot_history", class(plot))

  plot
}

#' Retrieve Plot Construction Code from ggplot_history Object
#'
#' Extracts the complete history of a ggplot object's construction,
#' providing a way to reproduce or inspect the plot. Designed to work
#' with ggplot objects of class 'ggplot_history'.
#'
#' @param plot A ggplot object of class 'ggplot_history'.
#' @param call `logical(1)` if `TRUE`, returns a callable expression
#' representing the plot construction.
#' If `FALSE`, returns a list of the history expressions.
#' By default `TRUE`
#'
#' @return Depending on the value of 'call', either a callable expression or
#' a list representing the history of the ggplot object.
#'
#' @examples
#' p <- ggplot(mtcars, aes(x=wt, y=mpg)) + geom_point()
#' plot_code <- get_ggplot_code(p)
#' print(plot_code)
#'
#' # eval(plot_code) # Reproduce the plot
#'
#' @export
#'
get_ggplot_code <- function(plot, call = TRUE) {
  stopifnot(inherits(plot, "ggplot_history"))
  history_attr <- attr(plot, "plot_history")
  if (call) {
    res <- Reduce(function(x, y) bquote(.(x) + .(y)), history_attr)
  } else {
    res <- history_attr
  }
  class(res) <- "ggplot_history_code"
  attr(res, "plot_history_env") <- attr(plot, "plot_history_env")
  res
}

#' Evaluate Plot Construction Code
#'
#' This function evaluates an expression representing a ggplot construction code.
#' It specifically uses the environment stored in the 'plot_history_env' attribute
#' of the expression, ensuring that the plot is reconstructed in the correct context.
#'
#' @param code An expression representing the ggplot construction code, typically
#'          generated by `get_ggplot_code`. This expression should have an
#'          attribute 'plot_history_env' that stores the environment in which
#'          the plot was originally created.
#'
#' @return The resulting ggplot object produced by evaluating the expression `x`.
#'
#' @examples
#' p <- ggplot(mtcars, aes(x=wt, y=mpg)) + geom_point()
#' plot_code <- get_ggplot_code(p)
#' reconstructed_plot <- eval_ggplot_code(plot_code)
#' print(reconstructed_plot)
#'
#' @export
#'
eval_ggplot_code <- function(code) {
  stopifnot(inherits(code, "ggplot_history_code"))
  validate_ggplot()
  eval(code, attr(code, "plot_history_env"))
}

#' @keywords internal
validate_ggplot <- function() {
  if (!requireNamespace("ggplot2")) {
    stop("ggplot2 package has to be installed.")
  }
}
