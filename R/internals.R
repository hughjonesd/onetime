
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
         "  * Call `onetime::ask_ok_to_score()` interactively and answer 'y' at the prompt\n",
         "  * Set options(\"onetime.dir\") to store files in a non-standard location")
}


# for mocking purposes
check_rlang <- function () {
  loadNamespace("rlang")
}


# for mocking purposes
my_interactive <- function () {
  interactive()
}


my_readline <- function (...) {
  readline(...)
}
