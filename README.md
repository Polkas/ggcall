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

## Example

`forest_plot`  and `barbell` functions are a part of `ggcall` package.
Typically, it will be a function returning `ggplot2` object from your own R package where you implemented `ggcall`.


```r
remotes::install_github("https://github.com/Polkas/ggcall")
library(ggcall)

# Print the body of the function
forest_plot

df <- data.frame(
  Treatment = c("Treatment A", "Treatment B", "Treatment C"),
  Estimate = c(0.2, 0.5, -0.1),
  CI_lower = c(0.1, 0.3, -0.3),
  CI_upper = c(0.3, 0.7, 0.1)
)

# Call the function, gg_plot is a ggplot object
gg_forest <- forest_plot(df, "Estimate", "CI_lower", "CI_upper", "Treatment")
gg_plot

# Retrieve the plot construction code
call_forest <- ggcall(gg_plot)

# Optionally: Style the code with styler
# install.packages("styler")
styler::style_text(paste(deparse(call_forest), collapse = "\n"))

# Optionally: add assignments to call
styler::style_text(paste(deparse(ggcall_add_assignments(call_forest)), collapse = "\n"))

# Optionally: reevaulate the call
eval_ggcall(call_forest)

df <- data.frame(
  Category = c("A", "B", "C", "D"),
  Before = c(3.5, 4.2, 2.8, 5.1),
  After = c(4.0, 4.5, 3.1, 5.5)
)

gg_barbell <- barbell_plot(df, "Category", "Before", "After", group_labels = c("Before", "After"))

call_barbell <- ggcall(gg_barbell)

eval_ggcall(gg_barbell)
```

## Implementation in Your Own Package

The ggcall can be implemented as a standalone solution.

A "standalone" file implements a minimum set of functionality in such a way that it can be copied into another package. 
`usethis::use_standalone()` makes it easy to get such a file into your own repo/package and later update it if needed.
[Example of standalone file in another package, rlang](https://github.com/r-lib/rlang/blob/main/R/standalone-purrr.R)

The `usethis` >= 2.2.0 is required.

```
install.packages("usethis")
```

STANDALONE means copy paste the files and add dependencies to your own package.

Please create an R package if not having such yet.

```
usethis::create_package()
```

WITH `patchwork` support

```
# Add ggplot2, patchwork as your package dependencies
# copy paste the ggcall.R file to your own package R directory
# copy paste the patchwork.R file to your own package R directory

usethis::use_standalone("polkas/ggcall", "patchwork.R", ref = "v0.3.3")
# you may need to update the files time to time with usethis::use_standalone
```

WITHOUT `patchwork` support

```
# Add ggplot2as your package dependencies
# copy paste the ggcall.R file to your own package R directory

usethis::use_standalone("polkas/ggcall", "ggcall.R", ref = "v0.3.3")
# you may need to update the files time to time with usethis::use_standalone
```

GENERAL COMMENTS:

```
# Apply only if needed
# In your own code remove all ggplot2:: prefix-ing before ggplot function calls
# ggplot2::ggplot(...) -> ggplot(...)
```

```
# DO NOT import ggplot function from ggplot2
#' @rawNamespace import(ggplot2, except = c(ggplot))
```

```
# Combine ggcall +.gg operator with your own one if you already overwrited it in your package
# e.g. GGally package requires such step
```

## Note

The solution is in the development and is expected not to work in specific situations.

## Contributions

Contributions to `ggcall` are welcome. Please refer to the contribution guidelines for more information.
