
#' @name common-params
#' @param id Unique ID. By default, name of the calling package.
#' @param path Directory to store lockfiles. By default, a per-user configuration
#'   directory `"onetime-lockfiles"` beneath [rappdirs::user_config_dir()].
#'
NULL


#' Print a warning or message only once
#'
#' These functions use [onetime_do()] to print a warning or message just
#' once.
#'
#' @param ... Passed to [warning()] or [message()].
#' @inherit common-params
#'
#' @return The return value of `warning()/message()`, or `NULL` if
#'   called a second time.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' id <- sample(10000L, 1)
#' for (n in 1:3) {
#'   onetime_warning("will be shown once", id = id)
#' }
#' }
onetime_warning <- function(...,
        id   = calling_package(),
        path = lockfile_dir()
      ) {
  onetime_do(warning(...), id, path)
}

#' @rdname onetime_warning
#' @export
onetime_message <- function (...,
        id   = calling_package(),
        path = lockfile_dir()
      ) {
  onetime_do(message(...), id, path)
}


#' Run code only once
#'
#' This function runs an expression just once. It then creates a lockfile
#' recording a unique ID which will prevent the expression being run again.
#'
#'
#' @param expr The code to evaluate
#' @inherit common-params
#'
#' @details
#' Calls are identified by `id`. If you use the same value of `id` across
#' different calls to `onetime_do()`, only the first call will get made.
#'
#' By default, `id` is just the name of the calling package. This is for the
#' common use case of a single call within a package (e.g. at first startup). If
#' you want to use multiple calls, or if the calling code is not within a
#' package, then you must set `id` explicitly.
#'
#' If the lockfile cannot be written, then the call will still be run, so it
#' may be run repeatedly.
#'
#' The default directory for lockfiles is `"onetime-lockfiles"` within
#' `rappdirs::user_config_dir()`.
#'
#' @return The value of `expr`, or `NULL` if called the second time.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' id <- sample(10000L, 1)
#' for (n in 1:3) {
#'   onetime_do(print("printed once"), id = id)
#' }
#' }
onetime_do <- function(
        expr,
        id   = calling_package(),
        path = lockfile_dir()
      ) {
  fp <- onetime_filepath(id, path)
  on.exit(file.create(fp))
  if (! file.exists(fp)) {
    return(invisible(eval.parent(expr)))
  }
}


#' Reset a onetime call by ID
#'
#' @inherit common-params
#'
#' @return The result of `file.remove()`.
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' id <- sample(10000L, 1)
#' onetime_do(print("will be shown"),  id = id)
#' onetime_do(print("won't be shown"), id = id)
#' onetime_reset(id = id)
#' onetime_do(print("will be shown"),  id = id)
#' }
onetime_reset <- function (
        id,
        path = system.file("lockfiles", package = "onetime")
) {
  fp <- onetime_filepath(id, path)
  file.remove(fp)
}


onetime_filepath <- function (id, path) {
  stopifnot(is.character(id), length(id) == 1, nchar(id) > 0,
        length(path) == 1, file.access(path, 2) == 0)
  file.path(path, id)
}


calling_package <- function () getNamespaceName(topenv(parent.frame(n = 2)))


lockfile_dir <- function () {
  file.path(rappdirs::user_config_dir(), "onetime-lockfiles")
}