# ---
# repo: polkas/ggcall
# file: patchwork
# last-updated: 2024-11-21
# license: https://unlicense.org
# dependencies: ggcall.R
# imports: [ggplot2, patchwork]
# ---
#
# This file provides a minimal shim to provide a ggcall functionality on top of
# ggplot2. Additionally patchwork operators are supported.
#
# ## Changelog
#

# nocov start

#' @keywords internal
patch_operator_base <- function(e1, e2, operator, class) {
  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("patchwork package has to be installed.")
  }
  plot <- utils::getFromNamespace(sprintf("%s.%s", operator, class), "patchwork")(e1, e2)
  if (inherits(e1, "ggcall") && inherits(e2, "ggcall")) {
    lhs <- ggcall(e1)
    rhs <- ggcall(e2)
    attr(plot, "ggcall") <- as.call(list(as.name(operator), lhs, rhs))
    attr(plot, "ggcall_env") <- merge_env(attr(e1, "ggcall_env"), attr(e2, "ggcall_env"))
    class(plot) <- unique(c("ggcall", class(plot)))
  }
  plot
}

#' @export
"-.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "-", "ggplot")
}

#' @export
"/.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "/", "ggplot")
}

#' @export
"|.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "|", "ggplot")
}

#' @export
"*.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "*", "gg")
}

#' @export
"&.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "&", "gg")
}

# nocov end
