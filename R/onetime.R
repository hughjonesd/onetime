

#' Run code only once
#'
#' This function runs an expression just once. It then creates a lockfile
#' recording a unique ID which will prevent the expression being run again.
#'
#' @param expr The code to evaluate. An R statement or [expression()] object.
#' @inherit common-params
#' @param default Value to return if `expr` was not executed.
#'
#' @details
#' Calls are identified by `id`. If you use the same value of `id` across
#' different calls to `onetime_do()` and similar functions, only the first
#' call will get made.
#'
#' By default, `id` is just the name of the calling package. This is for the
#' common use case of a single call within a package (e.g. at first startup).
#' If you want to use multiple calls, or if the calling code is not within a
#' package, then you *must* set `id` explicitly. If you are working in a
#' large project with many contributors, it is *strongly recommended to set*
#' `id ` *explicitly*.
#'
#' The default `path`, where lockfiles are stored, is within
#' [rappdirs::user_config_dir()] unless overridden by `options("onetime.dir")`.
#' If the lockfile cannot be written (e.g. because the user has not given
#' permission to store files on his or her computer), then the call will still
#' be run, so it may be run repeatedly. Conversely, if the call gives an error,
#' the lockfile is still written.
#'
#' @return The value of `expr`, invisibly; or `default` if `expr` was not run
#' because it had been run already.
#'
#' @export
#'
#' @examples
#' oo <- options(onetime.dir = tempdir(check = TRUE))
#' id <- sample(10000L, 1L)
#'
#' for (n in 1:3) {
#'   onetime_do(print("printed once"), id = id)
#' }
#'
#' onetime_reset(id = id)
#' options(oo)
onetime_do <- function(
        expr,
        id      = calling_package(),
        path    = default_lockfile_dir(),
        expiry  = NULL,
        default = NULL,
        without_permission = c("warn", "run", "stop", "pass", "ask")
      ) {
  do_onetime_do(expr = expr, id = id, path = path, expiry = expiry,
                default = default, without_permission = without_permission,
                require_permission = TRUE)
}


#' Wrap a function to be called only once
#'
#' This takes a function and returns the same function wrapped by [onetime_do()].
#' Use it for code which should run only once, but which may be called from
#' multiple locations. This frees you from having to use the same `id` multiple
#' times.
#'
#' @param .f A function
#' @inherit common-params
#'
#' @return A wrapped function.
#'
#' @export
#'
#' @seealso [onetime_do()]
#'
#' @examples
#' oo <- options(onetime.dir = tempdir(check = TRUE))
#' id <- sample(10000L, 1)
#'
#' sample_once <- onetime_only(sample, id = id)
#' sample_once(1:10)
#' sample_once(1:10)
#'
#' onetime_reset(id)
#' options(oo)
onetime_only <- function (
        .f,
        id   = calling_package(),
        path = default_lockfile_dir(),
        without_permission = "warn"
      ) {
  force(id)
  force(path)
  force(without_permission)
  function (...) onetime_do(.f(...), id = id, path = path,
                            without_permission = without_permission)
}
