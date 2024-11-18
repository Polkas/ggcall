# ggcall <a href='https://github.com/polkas/ggcall'><img src='man/figures/ggcall_logo.png' align="right" width="200px" /></a>
[![R build status](https://github.com/polkas/ggcall/workflows/R-CMD-check/badge.svg)](https://github.com/polkas/ggcall/actions)
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

## Details

Please access the [Get Started vignette](https://polkas.github.io/ggcall/articles/ggcall.html) for more information.

## Implementation

The ggcall can be implemented in a few ways.  
One of them is to copy and paste one or two R files to your package R directory.  
Another option is to use the ggcall as a DESCRIPTION file dependency for your package.

Please access the [Get Started vignette](https://polkas.github.io/ggcall/articles/ggcall.html) for more information.

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
eval_ggcall(plot_call, mtcars = mtcars[1:10, ], x = "disp")
```

Functions Reference:

| Function                | Description                                                                         |
|-------------------------|-------------------------------------------------------------------------------------|
| `ggplot`                | **Overrides the default `ggplot` function from the ggplot2 package, adding the capability to track the history of plot construction.**|
| `+.gg`                  | **Enhances the '+' operator for ggplot objects to track the history of plot layers and modifications.** |
| `ggcall`                | **Extracts the complete history of a ggplot object's construction, providing a way to reproduce or inspect the plot.**|
| `ggcall_add_assignments`| **Modifies a `ggcall()` object by adding variable assignments to it.**|
| `eval_ggcall`           | **Evaluates an expression representing a ggplot construction code.**|
| `ggcall_env`            | **Extracts the environment in which the ggplot construction code was originally created.**|
|`+`, `-`, `*`, `\|`, `&` and `/` | **Overloaded patchwork operators**|


## Note

The solution is in the development and is expected not to work in specific situations.

## Contributions

Contributions to `ggcall` are welcome. Please refer to the contribution guidelines for more information.
