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
#' oo <- options(onetime.dir = tempdir(check = TRUE))
#' id <- sample(10000L, 1)
#'
#' for (n in 1:3) {
#'   onetime_warning("will be shown once", id = id)
#' }
#'
#' onetime_reset(id = id)
#' options(oo)
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
#' Unlike other `onetime` functions, `onetime_message_confirm()` doesn't by
#' default require permission to store files on the user's computer. The
#' assumption is that saying "Don't show this message again" counts as
#' granting permission (just for this one message). You can ask for broader
#' permission by setting `require_permission = TRUE` and
#' `without_permission = "ask"`.
#'
#'
#' @inherit common-params
#' @param require_permission Logical. Ask permission to store files on the user's
#'  computer, if this hasn't been granted? Setting this to `FALSE`
#'  overrides `without_permission`.
#'
#' @return `NULL` if the message was not shown (shown already or non-interactive
#'   session). `TRUE` if the user confirmed (i.e. asked to hide the message).
#'   `FALSE` if the message was shown but the user did not confirm. Note that by
#'   default, `TRUE` is returned when the user answers "no" to "Show this message
#'   again?"
#'
#' @export
#'
#' @examples
#' oo <- options(onetime.dir = tempdir(check = TRUE))
#' id <- sample(10000L, 1L)
#'
#' onetime_message_confirm("A message to show one or more times", id = id)
#'
#' onetime_reset(id = id)
#' options(oo)
onetime_message_confirm <- function (message,
  id              = calling_package(),
  path            = default_lockfile_dir(),
  expiry          = NULL,
  confirm_prompt  = "Show this message again? [yN] ",
  confirm_answers = c("N", "n", "No", "no"),
  default_answer  = "N",
  require_permission  = FALSE,
  without_permission = "warn"
) {
  if (! my_interactive()) return(NULL)

  confirmation <- expression({
    message(message)
    answer <- my_readline(confirm_prompt)
    answer
  })

  answer <- do_onetime_do(confirmation, id = id, path = path, expiry = expiry,
                       without_permission = without_permission,
                       require_permission = require_permission)
  if (is.null(answer)) return(NULL)

  if (answer == "") answer <- default_answer
  if (! answer %in% confirm_answers) {
    onetime_reset(id, path)
  }

  return(answer %in% confirm_answers)
}
