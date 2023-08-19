
#' Run code only once
#'
#' Onetime allows package authors to run code only once (ever) for a given
#' user. It does so by writing a file, typically to a folder in the user's
#' configuration directory as given by [rappdirs::user_config_dir()]. The
#' user can set an alternative filepath using `options("onetime.dir")`.
#'
#' Core functions include:
#'
#' * [onetime_do()] runs arbitrary code only once.
#' * [onetime_warning()] and friends print a warning or message only once.
#' * [onetime_message_confirm()] prints a message and asks
#'   "Show this message again?"
#' * [onetime_rlang_warn()] and [onetime_rlang_inform()] print messages using
#'   functions from the rlang package.
#' * [onetime_only()] returns a function that runs only once.
#' * [check_ok_to_store()] and [set_ok_to_store()] check for or grant
#'   permission to store lockfiles on the user's computer.

#' It is package authors' responsibility to check for permission
#' to store lockfiles. This may have been done already by another package if
#' onetime was already installed. You can ask permission interactively on
#' the command line by calling [check_ok_to_store()] with `ask = TRUE`.
#'
#' For more information, see `vignette("onetime")`.
#'
#' @includeRmd example.Rmd
#'
#' @name onetime
#' @docType package
"_PACKAGE"

