# ONE FILE TO UPDATE AND ONE FILE TO CREATE
# UPDATE ggpairs_add.R and create ggcall.R

# UPDATE a function in ggpairs_add.R

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
#' gg_call <- ggcall(gg)
#' gg_call
#' # Optionally: Style the code with styler
#' # styler::style_text(deparse1(gg_call))
#' # Optional
#' # Access call environment and/or use it to evaluate the call
#' # as.list(ggcall_env(gg_call))
#' eval_ggcall(gg_call)
#'
"+.gg" <- function(e1, e2) {
  if (!is.ggmatrix(e1)) {
    stopifnot(inherits(e1, "ggcall"))
    validate_ggplot()
    plot <- utils::getFromNamespace("+.gg", "ggplot2")(e1, e2)

    # Append to the existing history
    if (!is.null(attr(e1, "ggcall"))) {
      history <- attr(e1, "ggcall")
    } else {
      history <- list()
    }
    history <- c(history, list(substitute(e2)))
    attr(plot, "ggcall") <- history

    if (!identical(attr(e1, "ggcall_env_last"), parent.frame())) {
      attr(plot, "ggcall_env") <- merge_env(attr(plot, "ggcall_env"), parent.frame())
    }

    attr(plot, "ggcall_env_last") <- parent.frame()
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

# CREATE A NEW file ggcall.R
# COPY PASTE THE WHOLE CODE FROM R/ggcall.R instead of +.gg function
