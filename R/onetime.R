
#' @name common-params
#' @param id Unique ID string. By default, name of the calling package.
#' @param path Directory to store lockfiles.
#' @param expiry [difftime()] or e.g. [lubridate::duration()] object.
#'   After this length of time, code will be run again.
#' @param message Message to display to the user.
#' @param confirm_prompt Character string. Question to prompt the user to hide
#'   the message in future.
#' @param confirm_answers Character vector. Answers which will cause
#'   the message to be hidden in future.
#' @param default_answer Character string. Default answer if user
#'   simply presses return.
#' @param without_permission Character string. What to do if the user hasn't given
#' permission to store files? `"warn"` runs the action with an extra warning;
#' `"run"` runs the action; `"pass"` does nothing and returns the default;
#' `"stop"` throws an error.
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
        expiry = NULL,
        without_permission = "warn"
      ) {
  ret_val <- onetime_do(warning(..., call. = FALSE), id = id, path = path, expiry = expiry,
                  default = FALSE, without_permission = without_permission)
  return(! isFALSE(ret_val))
}


#' @rdname onetime_warning
#' @export
onetime_message <- function (...,
        id     = calling_package(),
        path   = default_lockfile_dir(),
        expiry = NULL,
        without_permission = "warn"
      ) {
  ret_val <- onetime_do(message(...),  id = id, path = path, expiry = expiry,
                        default = FALSE, without_permission = without_permission)
  return(! isFALSE(ret_val))
}


#' @rdname onetime_warning
#' @export
onetime_startup_message <- function (...,
        id     = calling_package(),
        path   = default_lockfile_dir(),
        expiry = NULL,
        without_permission = "warn"
      ) {
  ret_val <- onetime_do(packageStartupMessage(...), id = id, path = path,
                        expiry = expiry, default = FALSE,
                        without_permission = without_permission)
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
#' @inherit common-params
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
  confirm_prompt  = "Show this message again? [yN] ",
  confirm_answers = c("N", "n", "No", "no"),
  default_answer  = "N",
  without_permission = "warn"
) {
  if (! my_interactive()) return(NULL)

  confirmation <- expression({
    message(message)
    answer <- my_readline(confirm_prompt)
    answer
  })

  answer <- onetime_do(confirmation, id = id, path = path, expiry = expiry,
                       without_permission = without_permission)
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
        default = NULL,
        without_permission = c("warn", "run", "stop", "pass")
      ) {
  force(id)
  force(path)
  without_permission = match.arg(without_permission)
  if (
    # see ask_ok_to_store()
    is.null(getOption("onetime.dont.recurse"))
  ) {
    got_confirmation <- check_ok_to_store()
    if (! got_confirmation) {
      switch(without_permission,
        warn = {
                 warning("Could not store onetime files.")
                 warning(options_info())
                 return(invisible(eval.parent(expr)))
               },
        run  = return(invisible(eval.parent(expr))),
        stop = stop("Could not store onetime files."),
        pass = return(default)
      )
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
        path = default_lockfile_dir(),
        without_permission = "warn"
      ) {
  force(id)
  force(path)
  force(without_permission)
  function (...) onetime_do(.f(...), id = id, path = path,
                            without_permission = without_permission)
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
  # don't check it's writable
  fp <- onetime_filepath(id = id, path = path, check_writable = FALSE)

  file.exists(fp)
}
