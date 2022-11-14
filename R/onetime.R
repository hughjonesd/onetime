
#' Run code only once
#'
#' Onetime allows package authors to run code only once (ever) for a given
#' user. It does so by writing a file, typically to a folder in the user's
#' configuration directory as given by [rappdirs::user_config_dir()]. The
#' user can set an alternative filepath using `options("onetime.dir")`.
#'
#' If loaded in an interactive session, the onetime package confirms
#' (once only) whether it has permission to write files to the
#' configuration directory. In a non-interactive session, it warns
#' the user that files will be written using [packageStartupMessage()].
#' This warning can be turned off by confirming permission interactively,
#' setting `options("onetime.dir")`, or setting
#' `options("onetime.ok_to_store" = TRUE)`. As a package author, you should
#' *only* set these options if you are sure you have the user's permission.
#'
#' @name onetime
#' @docType package
#' @includeRmd example.Rmd
#'
#' @details
#' * [onetime_do()] runs arbitrary code only once.
#' * [onetime_warning()] and friends print a warning or message only once.
#' * [onetime_message_confirm()] prints a message and asks
#'   "Show this message again?"
#'   [onetime_rlang_warn()] and [onetime_rlang_inform()] call [rlang::warn()]
#'   and [rlang::inform()] respectively.
#' * [onetime_only()] returns a function that runs only once.
#' * [onetime_reset()] resets a onetime call using a string ID.
NULL


#' @name common-params
#' @param id Unique ID string. By default, name of the calling package.
#' @param path Directory to store lockfiles.
#' @param expiry [difftime()] or e.g. [lubridate::duration()] object.
#'   After this length of time, code will be run again.
NULL


#' Print a warning or message only once
#'
#' These functions use [onetime_do()] to print a warning or message just
#' once.
#'
#' @param ... Passed to [warning()], [message()] or [packageStartupMessage()].
#' @inherit common-params
#'
#' @return `TRUE` if the message/warning was shown, `FALSE` otherwise.
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
#'
#' onetime_reset(id = id)
#' }
onetime_warning <- function(...,
        id     = calling_package(),
        path   = default_lockfile_dir(),
        expiry = NULL
      ) {
  ret_val <- onetime_do(warning(..., call. = FALSE), id = id, path = path, expiry = expiry,
                  default = FALSE)
  return(! isFALSE(ret_val))
}


#' @rdname onetime_warning
#' @export
onetime_message <- function (...,
        id     = calling_package(),
        path   = default_lockfile_dir(),
        expiry = NULL
      ) {
  ret_val <- onetime_do(message(...),  id = id, path = path, expiry = expiry,
                        default = FALSE)
  return(! isFALSE(ret_val))
}


#' @rdname onetime_warning
#' @export
onetime_startup_message <- function (...,
  id     = calling_package(),
  path   = default_lockfile_dir(),
  expiry = NULL
) {
  ret_val <- onetime_do(packageStartupMessage(...), id = id, path = path,
                        expiry = expiry, default = FALSE)
  return(! isFALSE(ret_val))
}


#' Print a message, and ask for confirmation to hide it in future
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
#' @param confirm_prompt Character string. Question to prompt the user to hide
#' the message in future
#' @param confirm_answers Character vector. Answers which will cause
#'   the message to be hidden in future. By default these are "no",
#'   because the question is phrased "Show this message again?".
#' @param default_answer Character string. Default answer if user
#'   simply presses return.
#'
#' @return `NULL` if the message was not shown (shown already or non-interactive
#' session). `TRUE` if the user confirmed (i.e. asked to hide the message).
#' `FALSE` if the user did not confirm. Note that by default,
#' `TRUE` is returned if the user answers "no" to "Show this message again?"
#'
#' @export
#'
#' @examples
#' \dontrun{
#' id <- sample(10000L, 1L)
#' onetime_message_confirm("A message to show one or more times", id = id)
#'
#' onetime_reset(id = id)
#' }
onetime_message_confirm <- function (message,
  id              = calling_package(),
  path            = default_lockfile_dir(),
  expiry          = NULL,
  confirm_prompt  = "Show this message again? [yN]",
  confirm_answers = c("N", "n", "No", "no"),
  default_answer  = "N"
) {
  if (! interactive()) return(NULL)

  # adding a space makes the readline nicer:
  confirm_prompt <- paste0(confirm_prompt, " ")
  confirmation <- expression({
    message(message)
    answer <- readline(confirm_prompt)
    answer
  })

  answer <- onetime_do(confirmation, id = id, path = path, expiry = expiry)
  if (is.null(answer)) return(NULL)

  if (answer == "") answer <- default_answer
  if (! answer %in% confirm_answers) {
    onetime_reset(id, path)
  }

  return(answer %in% confirm_answers)
}


#' Run code only once
#'
#' This function runs an expression just once. It then creates a lockfile
#' recording a unique ID which will prevent the expression being run again.
#'
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
#' The default `path`, where lockfiles are stored, is
#' `file.path(rappdirs::user_config_dir(), "onetime-lockfiles", mypackage)`.
#' `mypackage` is the calling package. If the calling code is not
#' within a package, then the default path is
#' `file.path(rappdirs::user_config_dir(), "onetime-lockfiles", "NO_PACKAGE")`.
#'
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
#' \dontrun{
#' id <- sample(10000L, 1L)
#' for (n in 1:3) {
#'   onetime_do(print("printed once"), id = id)
#' }
#'
#' onetime_reset(id = id)
#' }
onetime_do <- function(
        expr,
        id      = calling_package(),
        path    = default_lockfile_dir(),
        expiry  = NULL,
        default = NULL
      ) {
  force(id)
  force(path)
  if (
    # see confirm_ok_to_store()
    is.null(getOption("onetime.dont.recurse"))
  ) {
    got_confirmation <- confirm_ok_to_store()
    if (! got_confirmation) {
      warning("Could not record onetime action.")
      return(invisible(eval.parent(expr)))
    }
  }

  dir.create(path, showWarnings = FALSE, recursive = TRUE)
  fp <- onetime_filepath(id, path)

  lfp <- paste0(fp, ".lock")
  lck <- filelock::lock(lfp)
  on.exit(filelock::unlock(lck))

  file_exists <- file.exists(fp)
  file_expired <- if (file_exists && ! is.null(expiry)) {
    file.mtime(fp) + expiry < Sys.time()
  } else {
    FALSE
  }
  if (! file_exists || file_expired) {
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
#'
#' onetime_reset(id = id)
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


#' Check if a onetime call has already been made
#'
#' @inherit common-params
#'
#' @return `TRUE` if the lockfile recording the
#' onetime call exists, `FALSE` otherwise.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' id <- sample(10000L, 1)
#' onetime_been_done(id = id)
#' onetime_do(cat("Creating an ID"),  id = id)
#' onetime_been_done(id = id)
#'
#' onetime_reset(id = id)
#' }
onetime_been_done <- function (
        id   = calling_package(),
        path = default_lockfile_dir()
) {
  force(id)
  force(path)
  fp <- onetime_filepath(id, path)

  file.exists(fp)
}
