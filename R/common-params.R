

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
#' @param without_permission Character string. What to do if the user hasn't
#'   given permission to store files? `"warn"` runs the action with an extra
#'   warning; `"run"` runs the action; `"pass"` does nothing and returns the
#'   default; `"stop"` throws an error; `"ask"` asks for permission, after
#'   running the action but before recording it on disk.
NULL
