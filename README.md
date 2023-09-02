
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/onetime)](https://CRAN.R-project.org/package=onetime)
[![R-universe](https://hughjonesd.r-universe.dev/badges/onetime)](https://hughjonesd.r-universe.dev/onetime/)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/hughjonesd/onetime/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hughjonesd/onetime/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/hughjonesd/onetime/branch/master/graph/badge.svg)](https://app.codecov.io/gh/hughjonesd/onetime?branch=master)
<!-- badges: end -->

# onetime

> Listen very carefully. I shall say this only once.

[Michelle Dubois, *’Allo
’Allo*](https://www.youtube.com/watch?v=M-_5JJmNB6E)

The onetime package provides convenience functions to run R code only
once (ever) per user. For example, you can:

- Show a startup message only the first time (ever) that a package is
  loaded.
- Run cleanup code just once after an upgrade.
- Show the user a message, with the option not to show it again.

Onetime is a lightweight package. It requires just two package
dependencies, rappdirs and filelock, with no further indirect
dependencies. The total size including these dependencies is less than
50 Kb.

- For more information, see the
  [vignette](https://hughjonesd.github.io/onetime/dev/articles/onetime.html).

- Development documentation is at
  <https://hughjonesd.github.io/onetime/dev/>.

## Example

``` r
library(onetime)

ids  <- paste0("onetime-readme-", 1:3) 

for (i in 1:5) {
  onetime_do(cat("This command will only be run once.\n"), id = ids[1])
  onetime_warning("This warning will only be shown once.", id = ids[2])
  onetime_message("This message will only be shown once.", id = ids[3])
}
#> This command will only be run once.
#> Warning: This warning will only be shown once.
#> This message will only be shown once.
```

## Installation

Install onetime from [r-universe](https://r-universe.dev):

``` r
install.packages("onetime", repos = c("https://hughjonesd.r-universe.dev", 
                                      "https://cloud.r-project.org"))
```

Or on CRAN:

``` r
install.packages("onetime")
```

Or install the development version from github with:

``` r
# install.packages("remotes")
remotes::install_github("hughjonesd/onetime")
```
