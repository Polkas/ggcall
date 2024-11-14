#' @importFrom grid is.grob
#' @export
"-.ggcall" <- function(e1, e2) {
  validate_patchwork()
  plot <- utils::getFromNamespace("-.ggplot", "patchwork")(e1, e2)
  if (inherits(e1, "ggcall") && inherits(e2, "ggcall")) {
    attr(plot, "ggcall") <- bquote(.(ggcall(e1)) - .(ggcall(e2)))
    attr(plot, "ggcall_env") <- merge_env(attr(e1, "ggcall_env"), attr(e2, "ggcall_env"))
  }
  plot
}

#' @importFrom grid is.grob
#' @rdname plot_arithmetic
#' @export
"/.ggcall" <- function(e1, e2) {
  validate_patchwork()
  plot <- utils::getFromNamespace("/.ggplot", "patchwork")(e1, e2)
  if (inherits(e1, "ggcall") && inherits(e2, "ggcall")) {
    attr(plot, "ggcall") <- bquote(.(ggcall(e1)) / .(ggcall(e2)))
    attr(plot, "ggcall_env") <- merge_env(attr(e1, "ggcall_env"), attr(e2, "ggcall_env"))
  }
  plot
}
#' @importFrom grid is.grob
#' @rdname plot_arithmetic
#' @export
"|.ggcall" <- function(e1, e2) {
  validate_patchwork()
  plot <- utils::getFromNamespace("|.ggplot", "patchwork")(e1, e2)
  if (inherits(e1, "ggcall") && inherits(e2, "ggcall")) {
    attr(plot, "ggcall") <- bquote(.(ggcall(e1)) | .(ggcall(e2)))
    attr(plot, "ggcall_env") <- merge_env(attr(e1, "ggcall_env"), attr(e2, "ggcall_env"))
  }
  plot
}
#' @rdname plot_arithmetic
#' @export
"*.ggcall" <- function(e1, e2) {
  validate_patchwork()
  plot <- utils::getFromNamespace("*.gg", "patchwork")(e1, e2)
  if (inherits(e1, "ggcall") && inherits(e2, "ggcall")) {
    attr(plot, "ggcall") <- bquote(.(ggcall(e1)) * .(ggcall(e2)))
    attr(plot, "ggcall_env") <- merge_env(attr(e1, "ggcall_env"), attr(e2, "ggcall_env"))
  }
  plot
}
#' @rdname plot_arithmetic
#' @importFrom ggplot2 is.theme
#' @export
"&.ggcall" <- function(e1, e2) {
  validate_patchwork()
  plot <- utils::getFromNamespace("&.gg", "patchwork")(e1, e2)
  if (inherits(e1, "ggcall") && inherits(e2, "ggcall")) {
    attr(plot, "ggcall") <- bquote(.(ggcall(e1)) & .(ggcall(e2)))
    attr(plot, "ggcall_env") <- merge_env(attr(e1, "ggcall_env"), attr(e2, "ggcall_env"))
  }
  plot
}

#' @keywords internal
validate_patchwork <- function() {
  if (!requireNamespace("patchwork")) {
    stop("patchwork package has to be installed.")
  }
}
