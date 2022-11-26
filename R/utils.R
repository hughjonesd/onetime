

#' Reset a onetime call by ID
#'
#' @inherit common-params
#'
#' @return The result of `file.remove()`, invisibly.
#'
#'
#' @export
#'
#' @examples
#' oo <- options(onetime.dir = tempdir(check = TRUE))
#' id <- sample(10000L, 1)
#'
#' onetime_message("will be shown",  id = id)
#' onetime_message("won't be shown", id = id)
#' onetime_reset(id = id)
#' onetime_message("will be shown",  id = id)
#'
#' onetime_reset(id = id)
#' options(oo)
onetime_reset <- function (
        id   = calling_package(),
        path = default_lockfile_dir()
) {
  force(id)
  force(path)
  fp <- onetime_filepath(id, path)

  lfp <- paste0(fp, ".lock")
  lck <- filelock::lock(lfp)
  on.exit(filelock::unlock(lck))

  # invisible because you don't want to see the result on the command line
  invisible(file.remove(fp))
}


#' Mark an action as done
#'
#' This manually marks an action as done.
#'
#' Note that no `expiry` parameter is available, because `expiry` is
#' backward-looking. See [onetime_do()] for more information.
#'
#' Marking an action done requires permission to store files on the user's
#' computer, just like other onetime actions.
#'
#' @inherit common-params
#'
#' @return Invisible `TRUE` if the action represented
#' by `id` had not been done before, and has now been explicitly marked as done.
#' Invisible `FALSE` if it was already marked as done (and still is).
#' @export
#'
#' @examples
#' oo <- options(onetime.dir = tempdir(check = TRUE))
#' id <- sample(10000L, 1)
#'
#' onetime_mark_as_done(id = id)
#' onetime_message("Won't be shown", id = id)
#'
#' onetime_reset(id = id)
#' options(oo)
onetime_mark_as_done <- function (
        id   = calling_package(),
        path = default_lockfile_dir()
) {
  force(id)
  force(path)
  invisible(onetime_do(TRUE, id = id, path = path, default = FALSE))
}


#' Check if a onetime call has already been made
#'
#' @inherit common-params
#'
#' @return `TRUE` if the call has been recorded (within the
#' `expiry` time, if given).
#'
#' @export
#'
#' @examples
#' oo <- options(onetime.dir = tempdir(check = TRUE))
#' id <- sample(10000L, 1)
#'
#' onetime_been_done(id = id)
#' onetime_message("Creating an ID",  id = id)
#' onetime_been_done(id = id)
#'
#' onetime_reset(id = id)
#' options(oo)
onetime_been_done <- function (
        id   = calling_package(),
        path = default_lockfile_dir(),
	      expiry = NULL
) {
  force(id)
  force(path)
  # don't check it's writable
  fp <- onetime_filepath(id = id, path = path, check_writable = FALSE)

  if (! file.exists(fp)) {
    return(FALSE)
  }
  if (is.null(expiry)) {
    return(TRUE)
  } else {
    return(file.mtime(fp) + expiry >= Sys.time())
  }

}
