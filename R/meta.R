

#' Check if the package has permission to store files on the user's computer
#'
#' The onetime package works by storing lockfiles in
#' [rappdirs::user_config_dir()]. It won't do so unless permission has been
#' granted. Package authors should call `check_ok_to_store(ask = TRUE)` in
#' an interactive session, in functions which are called directly from the
#' command line.
#'
#' If your package is not used interactively, a workaround is to call
#' [set_ok_to_store()]. This grants permission and prints an informative
#' message. Package owners should *only* call this if they cannot ask
#' explicitly.
#'
#' @param ask `TRUE` to ask the user for permission.
#' @inherit common-params
#'
#' @details
#' `ask = TRUE` asks the user, if he or she has not already given permission,
#' and if the session is [interactive()].
#'
#' Remaining parameters are passed to [onetime_message_confirm()] in this case,
#' and ignored otherwise. A `"%s"` in `message` will be replaced by the
#' onetime storage directory.
#'
#' @return
#' `TRUE` if:
#'
#' * We already have permission;
#' * `ask` is `TRUE`, we are in an interactive session and the user
#'   gives us permission;
#' * `options("onetime.dir")` is set to a non-`NULL` value.
#'
#'  Otherwise `FALSE`.
#' @export
#'
#' @examples
#' \dontrun{
#' check_ok_to_store()
#' }
check_ok_to_store <- function(
    ask                = FALSE,
    message            = "The onetime package requests to store files in '%s'.",
    confirm_prompt     = "Is this OK? [Yn] ",
    confirm_answers    = c("Y", "y", "Yes", "yes", "YES"),
    default_answer     = "Y"
  ) {
  if (! is.null(getOption("onetime.dir"))) {
    # if onetime.dir has been set explicitly,
    # we assume we have permission to use it
    return(TRUE)
  }

  ok_to_store_id <- "ok-to-store"
  onetime_config_dir <- onetime_base_dir("")
  if (onetime_been_done(ok_to_store_id, onetime_config_dir)) {
    return(TRUE)
  } else if (ask && my_interactive()) {
    # omc_result can be NULL if user has been asked already (and said yes)
    # or if we're non-interactive. Hence we check now for interactive()
    # and convert NULL to TRUE below.
    message <- sprintf(message, onetime_config_dir)
    oo <- options("onetime.dont.recurse" = TRUE)
    on.exit(options(oo))
    omc_result <- onetime_message_confirm(
                    message         = message,
                    id              = ok_to_store_id,
                    path            = onetime_config_dir,
                    confirm_prompt  = confirm_prompt,
                    confirm_answers = confirm_answers,
                    default_answer  = default_answer
                  )

    return(! isFALSE(omc_result))
  } else {
    return(FALSE)
  }
}


#' Grant or revoke permission to store lockfiles on the user's computer
#'
#' @param ok `TRUE` to grant permission to store lockfiles, `FALSE` to revoke
#'   it and unset `options("onetime.dir")`#'
#' @return `TRUE` if the operation succeeded
#' @export
#'
#' @examples
#' \dontrun{
#' set_ok_to_store()
#' }
set_ok_to_store <- function (ok = TRUE) {
  ok_to_store_id <- "ok-to-store"
  onetime_config_dir <- onetime_base_dir("")
  if (isFALSE(ok)) {
    message("Revoking the onetime package's permission to store lockfiles on ",
            "this computer.")
    message("Setting options(\"onetime.dir\") to NULL.")
    options("onetime.dir" = NULL)
    onetime_reset(ok_to_store_id, onetime_config_dir)
  } else if (isTRUE(ok)) {
    message("Granting the onetime package permission to store lockfiles on ",
            "this computer.")
    # we recall so as to print the 'lockfiles' directory
    message("Lockfiles are stored beneath '", onetime_base_dir(), "'.")
    message("You can revoke permission by calling:")
    message("  onetime::set_ok_to_store(FALSE)")
    oo <- options("onetime.dont.recurse" = TRUE)
    on.exit(options(oo))
    onetime_do(TRUE, id = ok_to_store_id, path = onetime_config_dir,
               default = TRUE)
  } else {
    stop("`ok` was not TRUE or FALSE")
  }

  return(invisible(NULL))
}