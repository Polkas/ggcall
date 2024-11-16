# ggcall <a href='https://github.com/polkas/ggcall'><img src='man/figures/ggcall_logo.png' align="right" width="200px" /></a>
[![R build status](https://github.com/polkas/ggcall/workflows/R/badge.svg)](https://github.com/polkas/ggcall/actions)
[![codecov](https://codecov.io/gh/Polkas/ggcall/branch/main/graph/badge.svg)](https://app.codecov.io/gh/Polkas/ggcall)

## Overview

The `ggcall` package enhances the functionality of `ggplot2` by enabling users to retrieve the complete code used to generate a `ggplot` object. This package is beneficial for understanding and replicating complex `ggplot2` plots, especially when the original code is not accessible, e.g., hidden in the package's internals.

`ggcall` is especially useful for R developers who build their own packages comprising functions that generate `ggplot2` plots. These functions often involve multiple layers and complex plotting logic. By using `ggcall`, developers can make their plotting solutions more transparent and reproducible, thereby enhancing the utility and reliability of their packages. Please note, `ggcall` is not intended for packages that create custom geom/stat functions.

`ggcall` makes a developers life easier and limit the need to use base r metaprogramming or `rlang`.

An excellent implementation example is to create a bunch of ggplot templates, and we want them to be functions.
Then, each template will generate the expected plot, and the ggplot2 code behind is easy to get.

## Note

The solution is in the early development and is expected not to work in specific situations like with cowplot or when transition to grobs occurs.

## Usage

With `ggcall`, retrieving the construction calls of a `ggplot` object is straightforward:

```r
remotes::install_github("https://github.com/Polkas/ggcall")
library(ggcall)

# Example: Create a function which combines a few ggplot layers
# Typically, it will be a function from your R package where you implemented ggcall
func <- function(data, x, y, bool = TRUE) {
  # layers have to be added with +
  gg <- ggplot(data, aes(x = .data[[x]], y = .data[[y]])) +
    geom_point(alpha = 0.4) +
    facet_grid(~gear)
    
  if (bool) {
    gg <- gg + theme(axis.title.x = element_blank())
  }

  func_internal <- function(gg) {
    gg + labs(x = "custom xlab")
  }

  func_internal(gg)
}

# gg_plot is a ggplot object
gg_plot <- func(mtcars, "wt", "mpg")
print(gg_plot)
# Retrieve the plot construction code
plot_call <- ggcall(gg_plot)
plot_call
# ggplot(data, aes(x = .data[[x]], y = .data[[y]])) + geom_point(alpha = 0.4) + 
#     facet_grid(~gear) + theme(axis.title.x = element_blank()) + 
#     labs(x = "custom xlab")
# ...

# Optionally: Style the code with styler
# install.packages("styler")
styler::style_text(backports:::deparse1(plot_call))

# Optionally: add assignments to call
plot_call_with_assignments <- ggcall_add_assignments(plot_call)
styler::style_text(
  paste(deparse(plot_call_with_assignments), collapse = "\n")
)

# Optionally: access call environment
# Access call environment and/or use it to evaluate the call
plot_call_env <- ggcall_env(plot_call)
as.list(plot_call_env)

# Optionally: reevaulate the call
# Reproduce the plot by evaluating the code
eval_ggcall(plot_call)
eval_ggcall(plot_call_with_assignments)

# Optionally overwrite variables
eval_ggcall(plot_call, mtcars = mtcars[1:10, ], x = "gear")
```

## Features

- **Code Tracking**: Extends `ggplot2` `+` operator and `ggplot` function to track the history of plot construction.
- **Accessible History**: Easily access the complete sequence of `ggplot2` calls that were used to build a plot.
- **Reproducibility**: Facilitates the replication and modification of existing `ggplot2` plots.

## Implementation

### General

```
# Apply only if needed
# Remove all ggplot2:: prefix-ing before ggplot function calls
# ggplot2::ggplot(...) -> ggplot(...)
```

### OPTION 1

```
# copy paste the ggcall.R file to your own package
# you may need to update the file time to time
```

### OPTION 2

```
# ADD ggcall to Depends or Imports section in DESCRIPTION file
# If added to Depends then all ggcall functions will be preloaded when loading your own package
# If added to Imports the end user will have to library(ggcall) to get the ggcall functionalities
```

```
# DO NOT import ggplot function from ggplot2 instead import it from ggcall

# a. When importing all ggplot2 functions
# #' @rawNamespace import(ggplot2, except = c(ggplot))
# #' @import ggcall
# b. When importing specific ggplot2 functions
# #' @importFrom ggplot2 geom_line
# #' @importFrom ggcall ggplot
```

### Example implementation in GGally package

`ggcall` was successfully integrated into popular R packages like `GGally`. Please take into account that `GGally` had already overwritten the + `ggplot2` function. Thus, the overwriting practice seems to be popular.

These implementations demonstrate `ggcall`’s versatility and its capability to enhance the functionality of existing packages.

check out the inst/ggally.R for more details

```
remotes::install_github("https://github.com/Polkas/ggally")
library(GGally)

###########################
# Example for GGally ggcorr
###########################

data(mtcars)
gg <- GGally::ggcorr(
    mtcars,
    name = expression(rho),
    geom = "circle",
    max_size = 10,
    min_size = 2,
    size = 3,
    hjust = 0.75,
    nbreaks = 6,
    angle = -45,
    palette = "PuOr",
    legend.position = "top"
) + 
ggtitle("Correlation Matrix for mtcars Dataset")
# gg is a ggplot object
gg

# Retrieve the plot construction code
gg_call <- ggcall(gg)
gg_call

# Optionally: Style the code with styler
styler::style_text(deparse1(gg_call))

# Optionally: add assignments to call
gg_call_with_assignments <- ggcall_add_assignments(gg_call)
gg_call_with_assignments
styler::style_text(
  paste(deparse(gg_call_with_assignments), collapse = "\n")
)

# Optionally: reevaulate the call
# Reproduce the plot by evaluating the code
eval_ggcall(gg_call_with_assignments)
eval_ggcall(ggcall_add_assignments(gg_call))

##############################
# Example for GGally ggscatmat
##############################

data(iris)
gg <- GGally::ggscatmat(iris, color = "Species", columns = 1:4)
# gg is a ggplot object
gg

# Retrieve the plot construction code
gg_call <- ggcall(gg)
gg_call

# Optionally: Style the code with styler
styler::style_text(deparse1(gg_call))

# Optionally: add assignments to call
gg_call_with_assignments <- ggcall_add_assignments(gg_call)
gg_call_with_assignments
styler::style_text(
  paste(deparse(gg_call_with_assignments), collapse = "\n")
)

# Optionally: reevaulate the call
# Reproduce the plot by evaluating the code
eval_ggcall(gg_call)
eval_ggcall(gg_call_with_assignments)

##########################
# Example for GGally ggduo
##########################

# Not supported for ggmatrix like plots
# ggcall will fail as ggmatrix plots are not build with pure ggplot2

gg <- GGally::ggduo(tips, mapping = ggplot2::aes(colour = sex), columnsX = 3:4, columnsY = 1:2)
ggplot2::is.ggplot(gg)
# Fail gg_call <- ggcall(gg)
```

## Contributions

Contributions to `ggcall` are welcome. Please refer to the contribution guidelines for more information.
