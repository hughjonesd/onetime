
#' Run code only once
#'
#' Onetime allows package authors to run code only once (ever) for a given
#' user. It does so by writing a file, typically to the user's configuration
#' directory as given by [rappdirs::user_config_dir()].
#'
#' @name onetime
#' @docType package
#' @includeRmd example.Rmd
#'
#' @details
#' For more details, see [onetime_do()].
NULL


#' @name common-params
#' @param id Unique ID string. By default, name of the calling package.
#' @param path Directory to store lockfiles.
#'
NULL


#' Print a warning or message only once
#'
#' These functions use [onetime_do()] to print a warning or message just
#' once.
#'
#' @param ... Passed to [warning()], [message()] or [packageStartupMessage()].
#' @inherit common-params
#'
#' @return The return value of the underlying call, or `NULL` if
#'   called a second time.
#'
#' @export
#'
#' @seealso [onetime_do()]
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


#' @rdname onetime_warning
#' @export
onetime_startup_message <- function (...,
  id   = calling_package(),
  path = default_lockfile_dir()
) {
  onetime_do(packageStartupMessage(...), id, path)
}


#' Print a message, and ask if it should be printed again
#'
#' This uses [readline()] to ask the user if the message should
#' be shown again in future. In a non-interactive session, it does
#' nothing.
#'
#' By default, the message will be hidden if the user answers
#' "n", "No", or "N", or just presses return to the prompt question.
#'
#' @param message Message to print
#' @inherit common-params
#' @param confirm_prompt Question to prompt the user to hide the
#'   message in future
#' @param hide_answers Character vector. Answers which will cause
#'   the message to be hidden in future.
#' @param default_answer Character string. Default answer if user
#'   simply presses return.
#'
#' @return `NULL` if the message was not shown (shown already or non-interactive
#' session). `TRUE` if the user asked to show the message again.
#' `FALSE` if the user asked to hide the message.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' id <- sample(10000L, 1)
#' onetime_message_confirm("A message to show one or more times", id = id)
#' }
onetime_message_confirm <- function (message,
  id   = calling_package(),
  path = default_lockfile_dir(),
  confirm_prompt = "Show this message again? [yN]",
  hide_answers = c("N", "n", "No", "no"),
  default_answer = "N"
) {
  if (! interactive()) return(NULL)

  confirmation <- expression({
    message(message)
    answer <- readline(confirm_prompt)
    answer
  })

  answer <- onetime_do(confirmation, id = id, path = path)
  if (is.null(answer)) return(NULL)

  if (answer == "") answer <- default_answer
  if (! answer %in% hide_answers) {
    onetime_reset(id, path)
  }

  return(! answer %in% hide_answers)
}


#' Run code only once
#'
#' This function runs an expression just once. It then creates a lockfile
#' recording a unique ID which will prevent the expression being run again.
#'
#'
#' @param expr The code to evaluate
#' @inherit common-params
#' @param default Value to return if the code has been called a second or
#'   subsequent times.
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
#' The default `path`, where lockfiles are stored, is
#' `file.path(rappdirs::user_config_dir(), "onetime-lockfiles", mypackage)`.
#' `mypackage` is the calling package. If the calling code is not
#' within a package, then the default path is
#' `file.path(rappdirs::user_config_dir(), "onetime-lockfiles", "NO_PACKAGE")`.
#'
#' If the lockfile cannot be written, then the call will still be run, so it
#' may be run repeatedly. Conversely, if the call gives an error, the lockfile
#' is still written.
#'
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
        path = default_lockfile_dir(),
        default = NULL
      ) {
  force(id)
  force(path)
  dir.create(path, showWarnings = FALSE, recursive = TRUE)
  fp <- onetime_filepath(id, path)

  lfp <- paste0(fp, ".lock")
  lck <- filelock::lock(lfp)
  on.exit(filelock::unlock(lck))

  if (! file.exists(fp)) {
    file.create(fp)
    return(invisible(eval.parent(expr)))
  } else {
    return(default)
  }
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
#' \dontrun{
#' id <- sample(10000L, 1)
#'
#' cat_once <- onetime_only(cat, id = id)
#' cat_once("Purrr!")
#' cat_once("Miaow!")
#'
#' onetime_reset(id)
#' }
onetime_only <- function (
        .f,
        id   = calling_package(),
        path = default_lockfile_dir()
      ) {
  force(id)
  force(path)
  function (...) onetime_do(.f(...), id = id, path = path)
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
  force(id)
  force(path)
  fp <- onetime_filepath(id, path)

  lfp <- paste0(fp, ".lock")
  lck <- filelock::lock(lfp)
  on.exit(filelock::unlock(lck))

  invisible(file.remove(fp))
}


onetime_filepath <- function (id, path) {
  stopifnot(length(id) == 1, nchar(id) > 0,
        length(path) == 1, file.access(path, 2) == 0)
  file.path(path, id)
}


calling_package <- function (n = 2) {
  p <- parent.frame(n = n)
  tryCatch(
          getNamespaceName(topenv(p)),
          error = function (e) {
            if (grepl("not a namespace", e$message)) {
              stop("Could not identify calling package. Try setting `id` explicitly.")
            } else {
              e
            }
          }
        )
}


default_lockfile_dir <- function () {
  lfd <- file.path(rappdirs::user_config_dir(), "onetime-lockfiles")
  package <- try(calling_package(n = 3), silent = TRUE)
  if (inherits(package, "try-error")) package <- "NO-PACKAGE"
  lfd <- file.path(lfd, package)
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