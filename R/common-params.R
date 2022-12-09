

#' @name common-params
#' @param id Unique ID string. If this is unset, the name of the calling
#'   package will be used. Since onetime 0.2.0, not setting `id` is
#'   deprecated.
#' @param path Directory to store lockfiles. The default uses a unique
#'   directory corresponding to the calling package, beneath 
#'   [rappdirs::user_config_dir()]. Normally you should leave this as the 
#'   default.
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
#'   warning; `"run"` runs the action with no warning; `"pass"` does nothing
#'   and returns the default; `"stop"` throws an error; `"ask"` asks for
#'   permission using [check_ok_to_store()], and returns the default if it is
#'   not granted.
NULL
