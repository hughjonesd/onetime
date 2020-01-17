
#' @name common-params
#' @param id Unique ID. By default, name of the calling package.
#' @param path Path to store lockfiles. By default,
#'   `system.file("lockfiles", package = "onetime")`.
NULL


#' Print a warning or message only once
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
#' @param expr The code to evaluate
#' @inherit common-params
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


lockfile_dir <- function () getOption("onetime.lockfile_dir",
      system.file("lockfiles", package = "onetime"))