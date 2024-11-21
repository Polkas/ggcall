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

#' @title Base Function for Patchwork Operators
#' @description A helper function that applies patchwork operators to `ggcall` objects.
#' @param e1 The left-hand side `ggcall` object.
#' @param e2 The right-hand side `ggcall` object.
#' @param operator The operator as a string (e.g., "-", "/", "|", "*", "&").
#' @param class The class to which the operator is applied ("ggplot" or "gg").
#' @return A combined `ggcall` object resulting from the operation.
#' @import patchwork
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

#' @title Minus Operator for ggcall Objects
#' @description Applies the minus operator to `ggcall` objects, utilizing the corresponding operator from the `patchwork` package.
#' @details This function allows for the subtraction of `ggcall` objects using the `patchwork` syntax.
#' @inheritParams patch_operator_base
#' @return A combined `ggcall` object after applying the minus operation.
#' @keywords internal
#' @rdname ggcall-operators
#' @export
"-.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "-", "ggplot")
}

#' @title Division Operator for ggcall Objects
#' @description Applies the division operator to `ggcall` objects, utilizing the corresponding operator from the `patchwork` package.
#' @details This function allows for the division of `ggcall` objects using the `patchwork` syntax.
#' @inheritParams patch_operator_base
#' @return A combined `ggcall` object after applying the division operation.
#' @keywords internal
#' @rdname ggcall-operators
#' @export
"/.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "/", "ggplot")
}

#' @title Or Operator for ggcall Objects
#' @description Applies the or operator to `ggcall` objects, utilizing the corresponding operator from the `patchwork` package.
#' @details This function allows for the combination of `ggcall` objects using the `patchwork` syntax.
#' @inheritParams patch_operator_base
#' @return A combined `ggcall` object after applying the or operation.
#' @keywords internal
#' @rdname ggcall-operators
#' @export
"|.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "|", "ggplot")
}

#' @title Multiplication Operator for ggcall Objects
#' @description Applies the multiplication operator to `ggcall` objects, utilizing the corresponding operator from the `patchwork` package.
#' @details This function allows for the multiplication of `ggcall` objects using the `patchwork` syntax.
#' @inheritParams patch_operator_base
#' @return A combined `ggcall` object after applying the multiplication operation.
#' @keywords internal
#' @rdname ggcall-operators
#' @export
"*.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "*", "gg")
}

#' @title And Operator for ggcall Objects
#' @description Applies the and operator to `ggcall` objects, utilizing the corresponding operator from the `patchwork` package.
#' @details This function allows for the combination of `ggcall` objects using the `patchwork` syntax.
#' @inheritParams patch_operator_base
#' @return A combined `ggcall` object after applying the and operation.
#' @keywords internal
#' @rdname ggcall-operators
#' @export
"&.ggcall" <- function(e1, e2) {
  patch_operator_base(e1, e2, "&", "gg")
}


# nocov end
