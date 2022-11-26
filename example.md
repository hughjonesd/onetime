Documentation
================

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
```

    ## Loop  1  of 5
    ## This command will only be run once.

    ## Warning: This warning will only be shown once.

    ## This message will only be shown once.

    ## Loop  2  of 5
    ## Loop  3  of 5
    ## Loop  4  of 5
    ## Loop  5  of 5

``` r
# Meanwhile, in a separate process:
library(callr)
result <- callr::r(function (ids) {
  onetime::onetime_message("This message with an existing ID will not be shown.", id = ids[1])
  onetime::onetime_message("This message with a new ID will be shown.", id = ids[4])
}, show = TRUE, args = list(ids = ids))
```

    ## This message with an existing ID will not be shown.
    ## This message with a new ID will be shown.

``` r
# Letting the user hide a message:
onetime_message_confirm("A message that the user might want to hide.
                        In non-interactive sessions, instructions will
                        be shown for hiding it manually.", id = ids[5])
```

    ## A message that the user might want to hide.
    ##                         In non-interactive sessions, instructions will
    ##                         be shown for hiding it manually.
    ## To hide this message in future, run:
    ##   onetime_mark_as_done(id = "onetime-readme-483999030")

    ## [1] FALSE
