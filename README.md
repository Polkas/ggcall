# ggcall <a href='https://github.com/polkas/ggcall'><img src='man/figures/ggcall_logo.png' align="right" width="200px" /></a>
[![R build status](https://github.com/polkas/ggcall/workflows/R/badge.svg)](https://github.com/polkas/ggcall/actions)
[![codecov](https://codecov.io/gh/Polkas/ggcall/branch/main/graph/badge.svg)](https://app.codecov.io/gh/Polkas/ggcall)

## Overview

Transparency and reproducibility are fundamental principles in data analysis across various fields, from academic
research to industry applications. The `ggcall` package enhances the functionality of `ggplot2` by enabling users to retrieve the complete code used to generate a `ggplot` object inside a function. This package is beneficial for understanding and replicating complex `ggplot2` plots returned by a function. From technical point of view, `ggcall` extends `ggplot2` `+` operator and `ggplot` function to track the history of plot construction.

`ggcall` makes a developer's life easier and limits the need to use base r metaprogramming or `rlang`.

`patchwork` ggplot2 related operators like `+`, `-`, `*`, `|`, `&` and `/` are optionally supported. 
`patchwork` is a package that expands the API to allow for arbitrarily complex composition of plots by, 
among others, providing mathematical operators for combining multiple plots.

An excellent implementation example is to create a bunch of ggplot templates, and we want them to be functions.
Then, each template will generate the expected plot, and the ggplot2 code behind is easy to get.

## Note

The solution is in the early development and is expected not to work in specific situations like with cowplot or when transition to grobs occurs.

## Usage

Imagine using a package or function that generates a complex `ggplot2` visualization.  
Then, the ggplot code used to create the plot is not exposed.  
`ggcall` overcomes this barrier by extracting the hidden code, making it accessible for examination and modification. 

Here is a **simple** illustrative example with a scenario in which a function generates a `ggplot2` plot based on input data:

```r
remotes::install_github("https://github.com/Polkas/ggcall")
library(ggcall)

# Example: Create a function which combines a few ggplot layers
# Typically, it will be a function from your R package where you implemented ggcall
create_custom_plot <- function(data, x, y, bool = TRUE) {
  # layers have to be added with +
  gg <- ggplot(data, aes(x = .data[[x]], y = .data[[y]])) +
    geom_point(alpha = 0.4) +
    facet_grid(~gear)
    
  if (bool) {
    gg <- gg + theme(axis.title.x = element_blank())
  }

  func_internal <- function(gg) {
    gg + labs(title = "custom title")
  }

  func_internal(gg)
}

# gg_plot is a ggplot object
gg_plot <- create_custom_plot(mtcars, "wt", "mpg")
print(gg_plot)
# Retrieve the plot construction code
plot_call <- ggcall(gg_plot)
plot_call
# ggplot(data, aes(x = .data[[x]], y = .data[[y]])) + geom_point(alpha = 0.4) + 
#     facet_grid(~gear) + theme(axis.title.x = element_blank()) + 
#     labs(title = "custom title")
# attr(,"class")
# [1] "ggcall_code"
# attr(,"ggcall_env")
# <environment: abcd1234>
```

Here is a **more complex** illustrative example with `patchwork` usage and other `ggcall` utils functions.

<details>
<summary><strong>Click to Get the Example</strong></summary>

```r
remotes::install_github("https://github.com/Polkas/ggcall")
library(ggcall)
library(patchwork)

# Example: Create a function which combines a few ggplot layers
# Typically, it will be a function from your R package where you implemented ggcall
create_custom_plot <- function(data, x, y, bool = TRUE) {
  # layers have to be added with +
  gg <- ggplot(data, aes(x = .data[[x]], y = .data[[y]])) +
    geom_point(alpha = 0.4) +
    facet_grid(~gear)
    
  if (bool) {
    gg <- gg + theme(axis.title.x = element_blank())
  }

  func_internal <- function(gg) {
    gg + labs(title = "custom title")
  }

  # patchwork +
  func_internal(gg) + 
  # another ggplot added with patchwork
  ggplot(data, aes(x = .data[[x]], y = .data[[y]])) + 
  geom_point() + 
  theme(axis.title.y = element_blank(), axis.title.x = element_text(hjust = -0.15)) +
  plot_annotation(caption = "My Caption")
}

# gg_plot is a ggplot object
gg_plot <- create_custom_plot(mtcars, "wt", "mpg")
print(gg_plot)
# Retrieve the plot construction code
plot_call <- ggcall(gg_plot)
plot_call
# ggplot(data, aes(x = .data[[x]], y = .data[[y]])) + geom_point(alpha = 0.4) + 
#     facet_grid(~gear) + theme(axis.title.x = element_blank()) + 
#     labs(title = "custom title") + ggplot(data, aes(x = .data[[x]], 
#     y = .data[[y]])) + geom_point() + theme(axis.title.y = element_blank(), 
#     axis.title.x = element_text(hjust = -0.15)) + plot_annotation(caption = "My Caption")
# ...

# Optionally: Style the code with styler
# install.packages("styler")
styler::style_text(backports:::deparse1(plot_call))
# ggplot(data, aes(x = .data[[x]], y = .data[[y]])) +
#   geom_point(alpha = 0.4) +
#   facet_grid(~gear) +
#   theme(axis.title.x = element_blank()) +
#   labs(title = "custom title") +
#   ggplot(data, aes(x = .data[[x]], y = .data[[y]])) +
#   geom_point() +
#   theme(axis.title.y = element_blank(), axis.title.x = element_text(hjust = -0.15)) +
#   plot_annotation(caption = "My Caption")

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
eval_ggcall(plot_call, mtcars = mtcars[1:10, ], x = "disp")
```

</details>

## Implementation

The ggcall can be implemented in a few ways.  
One of them is to copy and paste one or two R files to your package R directory.  
Another option is to use the ggcall as a DESCRIPTION file dependency for your package.

### General

```
# Apply only if needed
# Remove all ggplot2:: prefix-ing before ggplot function calls
# ggplot2::ggplot(...) -> ggplot(...)
```

### OPTION 1

```
# copy paste the ggcall.R file to your own package
# OPTIONAL copy paste the patchwork.R file if you need patchwork support
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

A notable example of ggcall’s successful integration is seen in the `GGally` package fork.  
`GGally` package is a `ggplot2` extension used to create correlation matrices and scatterplot matrices.  
As `GGally` had already overwritten the `+.gg` operator to extend ggplot2’s functionality for their own reasons, demonstrating that overwriting operators can be considered an acceptable and practical solution.  

The `GGally` package required only minor changes to implement `ggcall`, showcasing how easily it can be integrated into existing solutions.   The copy and paste `ggcall` files to `GGally` are R/ggcall.R and OPTIONAL R/patchwork.R and the extended
already existing `+.gg` operator is located in R/ggpairs_add.R.

The `GGally` package fork with implemented `ggcall` is available on [Github](https://github.com/Polkas/ggally).  

<details>
<summary><strong>Click to See Example Implementation in GGally Package</strong></summary>

Here is an illustrative example with the `GGally::ggcorr` function from the fork with `ggcall`:

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
</details>

## Contributions

Contributions to `ggcall` are welcome. Please refer to the contribution guidelines for more information.
