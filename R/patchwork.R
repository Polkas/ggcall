patch_operator_base <- function(e1, e2, operator) {
  validate_patchwork()
  plot <- utils::getFromNamespace("-.ggplot", "patchwork")(e1, e2)
  if (inherits(e1, "ggcall") && inherits(e2, "ggcall")) {
    attr(plot, "ggcall") <- as.call(list(as.name(operator), ggcall(e1), ggcall(e2)))
    attr(plot, "ggcall_env") <- merge_env(attr(e1, "ggcall_env"), attr(e2, "ggcall_env"))
    class(plot) <- unique(c("ggcall", class(plot)))
  }
  plot
}

#' @export
"-.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "-")
}

#' @export
"/.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "/")
}

#' @export
"|.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "|")
}

#' @export
"*.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "*")
}

#' @export
"&.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "&")
}

#' @keywords internal
validate_patchwork <- function() {
  if (!requireNamespace("patchwork")) {
    stop("patchwork package has to be installed.")
  }
}
