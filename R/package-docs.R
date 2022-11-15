
#' Run code only once
#'
#' Onetime allows package authors to run code only once (ever) for a given
#' user. It does so by writing a file, typically to a folder in the user's
#' configuration directory as given by [rappdirs::user_config_dir()]. The
#' user can set an alternative filepath using `options("onetime.dir")`.
#'
#' It is package authors' responsibility to check for permission
#' to store lockfiles. This may have been done already by another package if
#' onetime was already installed. You can ask permission interactively on
#' the command line by calling `check_ok_to_store(ask = TRUE)`.
#'
#' This warning can be turned off by confirming permission interactively, or
#' setting `options("onetime.dir")`. As a package author, you should
#' *only* set these options if you are sure you have the user's permission.
#'
#'
#' # Core functions
#'
#' * [onetime_do()] runs arbitrary code only once.
#' * [onetime_warning()] and friends print a warning or message only once.
#' * [onetime_message_confirm()] prints a message and asks
#'   "Show this message again?"
#'   [onetime_rlang_warn()] and [onetime_rlang_inform()] call [rlang::warn()]
#'   and [rlang::inform()] respectively.
#' * [onetime_only()] returns a function that runs only once.
#' * [onetime_reset()] resets a onetime call using a string ID.
#' * [check_ok_to_store()] and [ask_ok_to_store()] confirm whether the user
#'   has granted permission to store lockfiles on his or her computer.
#'
#' @includeRmd example.Rmd
#'
#' @name onetime
#' @docType package

NULL

