
#' Run code only once
#'
#' @name onetime
#' @docType package
#' @includeRmd example.Rmd
NULL


#' @name common-params
#' @param id Unique ID. By default, name of the calling package.
#' @param path Directory to store lockfiles.
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
        path = default_lockfile_dir()
      ) {
  onetime_do(warning(...), id, path)
}

#' @rdname onetime_warning
#' @export
onetime_message <- function (...,
        id   = calling_package(),
        path = default_lockfile_dir()
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
#' common use case of a single call within a package (e.g. at first startup).
#' If you want to use multiple calls, or if the calling code is not within a
#' package, then you must set `id` explicitly.
#'
#' The default `path`, where lockfiles are stored, is
#' `file.path(rappdirs::user_config_dir(), "onetime-lockfiles", mypackage)`.
#' `mypackage` is the calling package. If the calling code is not
#' within a package, then the default path is
#' `file.path(rappdirs::user_config_dir(), "onetime-lockfiles")`.
#'
#' If the lockfile cannot be written, then the call will still be run, so it
#' may be run repeatedly.
#'
#' The mechanism is vulnerable to race conditions from multiple R sessions.
#' If you want to be absolutely sure that code never runs twice, you must
#' do something else.
#'
#' @return The value of `expr`, invisibly; or `NULL` if called the second time.
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
        path = default_lockfile_dir()
      ) {
  dir.create(path, showWarnings = FALSE, recursive = TRUE)
  fp <- onetime_filepath(id, path)
  if (! file.exists(fp)) {
    file.create(fp)
    return(invisible(eval.parent(expr)))
  }
}


#' Reset a onetime call by ID
#'
#' @inherit common-params
#'
#' @return The result of `file.remove()`, invisibly.
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
        id   = calling_package(),
        path = default_lockfile_dir()
) {
  fp <- onetime_filepath(id, path)
  invisible(file.remove(fp))
}


onetime_filepath <- function (id, path) {
  stopifnot(is.character(id), length(id) == 1, nchar(id) > 0,
        length(path) == 1, file.access(path, 2) == 0)
  file.path(path, id)
}


calling_package <- function () getNamespaceName(topenv(parent.frame(n = 3)))


default_lockfile_dir <- function () {
  lfd <- file.path(rappdirs::user_config_dir(), "onetime-lockfiles")
  package <- try(calling_package(), silent = TRUE)
  if (! inherits(package, "try-error")) lfd <- file.path(lfd, package)
  return(lfd)
}


.onLoad <- function (libname, pkgname) {
  lfd <- file.path(rappdirs::user_config_dir(), "onetime-lockfiles")
  if (! dir.exists(lfd)) {
    lfd_created <- dir.create(lfd)
    if (! lfd_created) warning(
          "Could not create onetime lockfile directory at ", lfd)
  }
}