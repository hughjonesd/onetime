
#' Print a warning or message only once using `rlang` functions
#'
#' If you use these you will need to add `"rlang"` to your package dependencies.
#'
#' @param ... Passed to [rlang::warn()] or [rlang::inform()].
#' @inherit common-params
#'
#' @return Invisibly: `TRUE` if the message/warning was shown, `FALSE` otherwise.
#'
#' @doctest
#' oo <- options(onetime.dir = tempdir(check = TRUE))
#' id <- sample(10000L, 1)
#'
#' for (n in 1:3) {
#' @expect warning(regexp = if (n == 1L) "rlang" else NA)
#'   onetime_rlang_warn(c("rlang-style warning", i = "Extra info"), id = id)
#' }
#'
#' onetime_reset(id = id)
#' options(oo)
#' @name onetime-rlang
NULL


#' @rdname onetime-rlang
#' @export
onetime_rlang_warn <- function (...,
        id     = deprecate_calling_package(),
        path   = default_lockfile_dir(),
        expiry = NULL,
        without_permission = "warn"
      ) {
  check_rlang()
  res <- onetime_do(
                    rlang::warn(...),
                    id = id, path = path, expiry = expiry,
                    without_permission = without_permission
                   )
  return(invisible(! is.null(res)))
}


#' @rdname onetime-rlang
#' @export
onetime_rlang_inform <- function (...,
        id     = deprecate_calling_package(),
        path   = default_lockfile_dir(),
        expiry = NULL,
        without_permission = "warn"
      ) {
  check_rlang()
  res <- onetime_do(
                    rlang::inform(...),
                    id = id, path = path, expiry = expiry,
                    # rlang::inform() returns NULL, so change default...
                    default = "not null",
                    without_permission = without_permission
                   )
  return(invisible(is.null(res))) # ... and return TRUE if you got NULL
}