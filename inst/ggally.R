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
#' # small function to display plots only if it's interactive
#' p_ <- GGally::print_if_interactive
#' data(tips)
#'
#' pm <- ggpairs(tips[, 2:4], ggplot2::aes(color = sex))
#' ## change to black and white theme
#' pm + ggplot2::theme_bw()
#' ## change to linedraw theme
#' p_(pm + ggplot2::theme_linedraw())
#' ## change to custom theme
#' p_(pm + ggplot2::theme(panel.background = ggplot2::element_rect(fill = "lightblue")))
#' ## add a list of information
#' extra <- list(ggplot2::theme_bw(), ggplot2::labs(caption = "My caption!"))
#' p_(pm + extra)
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