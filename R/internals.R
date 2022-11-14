
onetime_filepath <- function (id, path) {
  stopifnot(length(id) == 1, nchar(id) > 0,
        length(path) == 1, file.access(path, 2) == 0)
  file.path(path, id)
}


calling_package <- function (n = 2) {
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

onetime_base_dir <- function () {
  lfd <- file.path(rappdirs::user_config_dir(), "onetime-lockfiles")
  getOption("onetime.dir", lfd)
}


.onLoad <- function (libname, pkgname) {
  lfd <- onetime_base_dir()
  options_info <- paste0("Set options('onetime.dir') to an existing directory ",
                          "to use a non-standard location.")

  ok <- if (! is.null(getOption("onetime.dir"))) {
    # if option has been set explicitly,
    # we assume we have permission to use it
    TRUE
  } else {
    id <- "onetime-basic-confirmation"
    path <- rappdirs::user_config_dir()
    if (interactive()) {
      msg <- paste0("The 'onetime' package needs to save configuration files ",
                  "on disk at '", lfd, "'. ")
      prompt <- "Create this folder and store files there? [Yn]"
      onetime_message_confirm(
        message         = msg,
        id              = id,
        path            = path,
        confirm_prompt  = prompt,
        confirm_answers = c("Y", "y", "Yes", "yes", "YES"),
        default_answer  = "Y"
      )
    } else {
      onetime_startup_message(paste0(
                              "'onetime' package saving configuration files ",
                              "in '", lfd, "'. ", options_info),
                              id   = id,
                              path = path
                            )
      TRUE
    }
  }

  if (isTRUE(ok) || is.null(ok)) {
    if (! dir.exists(lfd)) {
      lfd_created <- dir.create(lfd)
      if (! lfd_created) {
        warning("Could not create onetime directory at '", lfd, "'. ",
                "Some functions may not work as expected. ",
                options_info)
      }
    }
  } else {
    # ok FALSE: user explicitly said NOT to create the default directory
    warning("Onetime directory not created. ",
            "Some functions may not work as expected. ",
            options_info)
  }
}


no_rlang_message <- function (caller) {
  paste0("In addition: package \"rlang\" not installed in ", caller)
}


# for mocking purposes
require_rlang <- function (){
  requireNamespace("rlang", quietly = TRUE)
}