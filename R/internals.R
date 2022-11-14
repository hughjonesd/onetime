
onetime_filepath <- function (id, path, check_writable = TRUE) {
  stopifnot(length(id) == 1L, nchar(id) > 0L, length(path) == 1L)
  if (check_writable) {
    isdir <- file.info(path)$isdir
    # unname to work around earlier versions of isTRUE not liking names
    if (! isTRUE(unname(isdir))) {
      stop("'", path, "' is not a directory")
    }
    if (! file.access(path, 2) == 0L) {
      stop("Could not write to '", path, "'")
    }
  }
  file.path(path, id)
}


calling_package <- function (n = 2L) {
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
  lfd <- onetime_base_dir()
  package <- try(calling_package(n = 3), silent = TRUE)
  if (inherits(package, "try-error")) package <- "NO-PACKAGE"
  lfd <- file.path(lfd, package)
  return(lfd)
}

onetime_base_dir <- function (bottom_dir = "onetime-lockfiles") {
  lfd <- rappdirs::user_config_dir("onetime")
  if (! bottom_dir == "") lfd <- file.path(lfd, bottom_dir)
  getOption("onetime.dir", lfd)
}


options_info <- function (){
  paste0("To avoid warning messages, either:\n",
         "* Call library(onetime) in an interactive session ",
         "and confirm you are OK to store files on your computer\n",
         "* Set options(\"onetime.ok_to_store\" = TRUE)\n",
         "* Set options(\"onetime.dir\") to store files in a non-standard location")
}

.onLoad <- function (libname, pkgname) {
  ok <- confirm_ok_to_store()

  if (isTRUE(ok)) {
    lfd <- onetime_base_dir()
    if (! dir.exists(lfd)) {
      lfd_created <- dir.create(lfd, recursive = TRUE)
      if (! lfd_created) {
        warning("Could not create onetime directory at '", lfd, "'. ",
                "Some functions may not work as expected.\n",
                options_info())
      }
    }
  } else {
    # ok FALSE: user explicitly said NOT to create the default directory
    warning("Onetime directory not created. ",
            "Some functions may not work as expected.\n",
            options_info())
  }
}


#' Check if user is OK with us writing files
#'
#' This returns TRUE unless the user explicitly answers no when asked if
#' we can write files. However, we keep asking until the user either
#' sets options("onetime.dir"), sets options("onetime.ok_to_store") or answers yes.
#' @return TRUE or FALSE
#' @noRd
confirm_ok_to_store <- function () {
  if (! is.null(getOption("onetime.dir")) ||
      isTRUE(getOption("onetime.ok_to_store"))) {
    # if onetime.dir has been set explicitly,
    # we assume we have permission to use it
    return(TRUE)
  } else {
    lfd <- onetime_base_dir()
    if (interactive()) {
      # this is a hacky longjump to avoid recursing when we call
      # onetime_message_confirm below
      oo <- options("onetime.dont.recurse" = TRUE)
      on.exit(options(oo))
      msg <- paste0("The 'onetime' package needs to save configuration files ",
                  "on disk at '", lfd, "'. ")
      prompt <- "Create this folder and store files there? [Yn]"
      omc_result <- onetime_message_confirm(
                      message         = msg,
                      id              = "onetime-basic-confirmation",
                      path            = onetime_base_dir(""),
                      confirm_prompt  = prompt,
                      confirm_answers = c("Y", "y", "Yes", "yes", "YES"),
                      default_answer  = "Y"
                    )
      # if this is NULL, it is because message was shown already,
      # not because we are in a non-interactive session
      ok <- is.null(omc_result) || isTRUE(omc_result)
      return(ok)
    } else {
      already_confirmed <- onetime_been_done(
                             id   = "onetime-basic-confirmation",
                             path = onetime_base_dir("")
                           )
      # we don't use onetime_message() here because it's not enough
      # to message the user once - they must explicitly confirm they are OK
      # otherwise we keep asking
      if (! already_confirmed) {
        message("'onetime' package saving configuration files in '",
              lfd, "'.\n", options_info())
      }
      return(TRUE)
    }
  }
}


no_rlang_message <- function (caller) {
  paste0("In addition: package \"rlang\" not installed in ", caller)
}


# for mocking purposes
require_rlang <- function (){
  requireNamespace("rlang", quietly = TRUE)
}