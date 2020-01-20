
# onetime

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/hughjonesd/onetime.svg?branch=master)](https://travis-ci.org/hughjonesd/onetime)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/onetime?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/onetime)
[![Codecov test
coverage](https://codecov.io/gh/hughjonesd/onetime/branch/master/graph/badge.svg)](https://codecov.io/gh/hughjonesd/onetime?branch=master)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

`onetime` provides convenience functions to run R code only once per
user. For example, you can show a startup message only the first time
(ever) that a package is loaded.

## Example

``` r
library(onetime)
ids  <- paste0("onetime-readme-", sample(1e9, 3))


for (i in 1:5) {
  cat("Loop ", i, " of 5\n")
  onetime_do(cat("You will only see this once.\n"), id = ids[1])
  onetime_warning("This warning will only be shown once.", 
      id = ids[2])
  onetime_message("This message will only be shown once.", id = ids[3])
}
#> Loop  1  of 5
#> You will only see this once.
#> Warning in eval(expr, p): This warning will only be shown once.
#> This message will only be shown once.
#> Loop  2  of 5
#> Loop  3  of 5
#> Loop  4  of 5
#> Loop  5  of 5
```

## Installation

You can install the released version of onetime from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("onetime")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("hughjonesd/onetime")
```
