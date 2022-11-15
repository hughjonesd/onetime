#' Check if the package has permission to store files on the user's computer
#'
#' @param ask `TRUE` to call [ask_ok_to_store()] if necessary.
#' @param ... Passed to [ask_ok_to_store()] if `ask` is `TRUE`.
#'
#' @return
#' `TRUE` if:
#'
#' * We already have permission;
#' * `ask` is `TRUE`, we are in an interactive session and the user
#'   gives us permission;
#' * `options("onetime.dir")` is set to a non-`NULL` value
#'
#'  Otherwise `FALSE`.
#' @export
#'
#' @examples
#' \dontrun{
#' check_ok_to_store()
#' }
check_ok_to_store <- function(ask = FALSE, ...) {
  if (! is.null(getOption("onetime.dir"))) {
    # if onetime.dir has been set explicitly,
    # we assume we have permission to use it
    return(TRUE)
  }

  obd <- onetime_base_dir("")
  ok_to_store_file <- onetime_been_done("ok-to-store", obd)
  if (ok_to_store_file) {
    return(TRUE)
  } else if (ask) {
    return(ask_ok_to_store(...))
  } else {
    return(FALSE)
  }
}


#' Ask the user if it is OK to store files on their computer
#'
#' @inherit common-params
#'
#' @return `TRUE` if the user gives permission (or has done so previously).
#' Does nothing and returns `FALSE` if not interactive. `FALSE` if the user
#' does not give permission.
#' @export
#'
#' @examples
#' \dontrun{
#'   ask_ok_to_store()
#' }
ask_ok_to_store <- function(
    message            = "The onetime package requests to store files in '%s'.",
    confirm_prompt     = "Is this OK? [Yn] ",
    confirm_answers    = c("Y", "y", "Yes", "yes", "YES"),
    default_answer     = "Y"
  ) {
  oo <- options("onetime.dont.recurse" = TRUE)
  on.exit(options(oo))

  obd <- onetime_base_dir("")
  message <- sprintf(message, obd)

  omc_result <- onetime_message_confirm(
                  message         = message,
                  id              = "ok-to-store",
                  path            = obd,
                  confirm_prompt  = confirm_prompt,
                  confirm_answers = confirm_answers,
                  default_answer  = default_answer
                )

  return(! isFALSE(omc_result))
}
