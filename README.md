
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/onetime)](https://CRAN.R-project.org/package=onetime)
[![R-universe](https://hughjonesd.r-universe.dev/badges/onetime)](https://hughjonesd.r-universe.dev/ui#package:onetime)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/hughjonesd/onetime/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hughjonesd/onetime/actions/workflows/R-CMD-check.yaml)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/onetime?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/onetime)
[![Codecov test
coverage](https://codecov.io/gh/hughjonesd/onetime/branch/master/graph/badge.svg)](https://app.codecov.io/gh/hughjonesd/onetime?branch=master)
<!-- badges: end -->

# onetime

> Listen very carefully. I shall say this only once.

Michelle Dubois, *’Allo ’Allo*

The onetime package provides convenience functions to run R code only
once per user. For example, you can show a startup message only the
first time (ever) that a package is loaded.

For more information, see the
[website](https://hughjonesd.github.io/onetime/).

## Example

``` r
library(onetime)
ids  <- paste0("onetime-readme-", sample(1e9, 5L))


for (i in 1:5) {
  cat("Loop ", i, " of 5\n")
  onetime_do(cat("This command will only be run once.\n"), id = ids[1])
  onetime_warning("This warning will only be shown once.", id = ids[2])
  onetime_message("This message will only be shown once.", id = ids[3])
}
#> Loop  1  of 5
#> This command will only be run once.
#> Warning: This warning will only be shown once.
#> This message will only be shown once.
#> Loop  2  of 5
#> Loop  3  of 5
#> Loop  4  of 5
#> Loop  5  of 5

# Meanwhile, in a separate process:
library(callr)
result <- callr::r(function (ids) {
  onetime::onetime_message("This message with an existing ID will not be shown.", id = ids[1])
  onetime::onetime_message("This message with a new ID will be shown.", id = ids[4])
}, show = TRUE, args = list(ids = ids))
#> This message with an existing ID will not be shown.
#> This message with a new ID will be shown.


# Printing a message with the ability to hide it in future
# onetime_message_confirm("A message that the user might want to hide.
#                         In non-interactive sessions, instructions will
#                         be shown for hiding it manually.", id = ids[5])
```

## Installation

Onetime is now on CRAN. You can install it with:

``` r
install.packages("onetime")
```

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("hughjonesd/onetime")
```
