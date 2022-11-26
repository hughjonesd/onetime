

IDS <- character(0)

test_id <- function (id) {
  id <- paste0("messages-", id)
  IDS <<- c(IDS, id)
  IDS <<- unique(IDS)
  return(id)
}

oo <- options(onetime.dir = tempdir(check = TRUE))


test_that("onetime_warning/message/startup_message", {
  expect_warning(
          rv <- onetime_warning("foo", id = test_id("test-id-3")),
          "foo"
        )
  expect_true(rv)
  expect_silent(rv <- onetime_warning("foo", id = test_id("test-id-3")))
  expect_false(rv)

  expect_message(
    rv <- onetime_message("foo", id = test_id("test-id-4")),
    "foo"
  )
  expect_true(rv)
  expect_silent(rv <- onetime_message("foo", id = test_id("test-id-4")))
  expect_false(rv)

  expect_message(
    rv <- onetime_startup_message("foo", id = test_id("test-id-5")),
    "foo"
  )
  expect_true(rv)
  expect_silent(rv <- onetime_startup_message("foo", id = test_id("test-id-5")))
  expect_false(rv)
})


test_that("onetime_message_confirm", {

  if (! interactive()) {
    mockr::local_mock(
      my_interactive = function () TRUE,
      my_readline = function (...) INPUT
    )
  }

  INPUT <- "y"
  expect_message(
    rv <- onetime_message_confirm("Say Y",
                                  confirm_prompt = "Please enter y ",
                                  id = test_id("test-id-omc"))
  )
  expect_false(rv) # because user did not confirm to hide the message

  INPUT <- "n"
  expect_message(
    rv <- onetime_message_confirm("Say N",
                                  confirm_prompt = "Please enter n ",
                                  id = test_id("test-id-omc"))
  )
  expect_true(rv)

  expect_silent(
    rv <- onetime_message_confirm("Should be hidden",
                                  id = test_id("test-id-omc"))
  )
  expect_null(rv)

  lifecycle::expect_deprecated(
    onetime_message_confirm(message = "Should be ...",
                            id = test_id("test-id-omc-deprecated"))
  )
})


test_that("onetime_message_confirm require_permission", {
  mockr::local_mock(
    check_ok_to_store = function (...) FALSE,
    my_readline = function (...) INPUT # don't know why I have to say this again
                                       # but it seems I do...
  )
  INPUT <- "n"
  expect_message(
    rv <- onetime_message_confirm("Say N",
                                 confirm_prompt = "Please enter n ",
                                 id = test_id("test-id-omc-2"),
                                 require_permission = FALSE)
  )
})


test_that("onetime_message_confirm noninteractive", {
  mockr::local_mock(
    check_ok_to_store = function (...) TRUE,
    my_interactive = function (...) FALSE,
  )

  expect_message(
    onetime_message_confirm("onetime_message_confirm",
                            id = test_id("test-id-omc-3")),
    "onetime_mark_as_done"
  )

  expect_silent(
    onetime_message_confirm("onetime_message_confirm", noninteractive = NULL,
                            id = test_id("test-id-omc-4"))
  )
})


for (id in IDS) {
  suppressWarnings(onetime_reset(id))
}
rm(IDS)

options(oo)