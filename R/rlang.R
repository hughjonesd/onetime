


#' Print a warning or message only once using `rlang` functions
#'
#' If rlang is not installed, these fall back to [onetime_warning()] and
#' [onetime_message()], adding a note about rlang.
#'
#' @param ... Passed to [rlang::warn()] or [rlang::inform()]
#' @inherit common-params
#'
#' @return `TRUE` if the message/warning was shown, `FALSE` otherwise.
#'
#' @examples
#' \dontrun{
#' id <- sample(10000L, 1)
#' for (n in 1:3) {
#'   onetime_rlang_warn(c("rlang-style warning", i = "Extra info"), id = id)
#' }
#' }
#' @name onetime-rlang
NULL


#' @rdname onetime-rlang
#' @export
onetime_rlang_warn <- function (...,
        id     = calling_package(),
        path   = default_lockfile_dir(),
        expiry = NULL) {
  if (require_rlang()) {
    res <- onetime_do(
                      rlang::warn(...),
                      id = id, path = path, expiry = expiry
                     )
    return(! is.null(res))
  } else {
    res <- onetime_warning(..., "\n", no_rlang_message("`onetime_rlang_warn()`"),
                           id = id, path = path, expiry = expiry)
    return(res)
  }
}


#' @rdname onetime-rlang
#' @export
onetime_rlang_inform <- function (...,
        id     = calling_package(),
        path   = default_lockfile_dir(),
        expiry = NULL) {
  if (require_rlang()) {
    res <- onetime_do(
                      rlang::inform(...),
                      id = id, path = path, expiry = expiry,
                      # rlang::inform() returns NULL, so change default...
                      default = "not null"
                     )
    return(is.null(res)) # ... and return TRUE if you got NULL
  } else {
    res <- onetime_message(..., "\n", no_rlang_message("`onetime_rlang_inform()`"),
                           id = id, path = path, expiry = expiry)
    return(res)
  }
}


no_rlang_message <- function (caller) {
  paste0("In addition: package \"rlang\" not installed in ", caller)
}

# for mocking purposes
require_rlang <- function (){
  requireNamespace("rlang", quietly = TRUE)
}
