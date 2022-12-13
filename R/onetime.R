
#' Run code only once
#'
#' When first called, `onetime_do()` evaluates an expression. It then creates a
#' lockfile recording a unique ID which will prevent the expression being run
#' on subsequent calls.
#'
#'
#' @param expr The code to evaluate. An R statement or [expression()] object.
#' @inherit common-params
#' @param default Value to return if `expr` was not executed.
#'
#' @details
#' `onetime_do()` is the engine used by other onetime functions.
#'
#' Calls are identified by `id`. If you use the same value of `id` across
#' different calls to onetime functions, only the first call will get made.
#'
#' The default `path`, where lockfiles are stored, is in a per-package directory
#' beneath [rappdirs::user_config_dir()]. To use a different subdirectory within
#' the onetime base directory, set `path = onetime_dir("dirname")`.
#'
#' End users can also set `options(onetime.dir)` to change the base directory.
#' Package authors should only set this option locally within package functions,
#' if at all.
#'
#' If the call gives an error, the lockfile is still written.
#'
#' `expiry` is backward-looking. That is, `expiry` is used at check time to see
#' if the lockfile was written after `Sys.time() - expiry`. It is not used when
#' the lockfile is created. So, you should set `expiry` to the same value
#' whenever you call `onetime_do()`. See the example.
#'
#' @return `onetime_do()` invisibly returns the value of `expr`,
#' or `default` if `expr` was not run because it had been run already.
#'
#' @export
#'
#' @doctest
#' oo <- options(onetime.dir = tempdir(check = TRUE))
#' id <- sample(10000L, 1L)
#'
#' for (n in 1:3) {
#' @expect output(regexp = if (n == 1L) "once" else NA)
#'   onetime_do(print("printed once"), id = id)
#' }
#'
#' # expiry is "backward-looking":
#' id2 <- sample(10000L, 1L)
#' expiry <- as.difftime(1, units = "secs")
#' onetime_do(print("Expires quickly, right?"), id = id2, expiry = expiry)
#' Sys.sleep(2)
#' @expect silent()
#' onetime_do(print("This won't be shown..."), id = id2)
#' @expect output("but this will")
#' onetime_do(print("... but this will"), id = id2, expiry = expiry)
#'
#'
#' onetime_reset(id = id)
#' onetime_reset(id = id2)
#' options(oo)
onetime_do <- function(
        expr,
        id      = deprecate_calling_package(),
        path    = default_lockfile_dir(),
        expiry  = NULL,
        default = NULL,
        without_permission = c("warn", "run", "stop", "pass", "ask")
      ) {
  do_onetime_do(expr = expr, id = id, path = path, expiry = expiry,
                default = default, without_permission = without_permission,
                require_permission = TRUE, invisibly = TRUE)
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
#' @param default Value to return from `.f` if function was not executed.
#'
#' @return
#' A wrapped function. The function itself returns the result of `.f`,
#' or  `default` if the inner function was not called.
#'
#' @export
#'
#' @seealso [onetime_do()]
#'
#' @doctest
#' oo <- options(onetime.dir = tempdir(check = TRUE))
#' id <- sample(10000L, 1)
#'
#' sample_once <- onetime_only(sample, id = id)
#' @expect length(10)
#' sample_once(1:10)
#' @expect null()
#' sample_once(1:10)
#'
#' onetime_reset(id)
#' options(oo)
onetime_only <- function (
        .f,
        id = deprecate_calling_package(),
        path = default_lockfile_dir(),
	      default = NULL,
        without_permission = "warn"
      ) {
  force(id)
  force(path)
  force(without_permission)
  function (...) {
    do_onetime_do(.f(...), id = id, path = path,
                            without_permission = without_permission,
			    default = default, invisibly = FALSE)
  }
}
