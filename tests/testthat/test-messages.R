

IDS <- character(0)

test_id <- function (id) {
  id <- paste0("messages-", id)
  IDS <<- c(IDS, id)
  IDS <<- unique(IDS)
  return(id)
}

# set explicitly from here on
oo <- options("onetime.dir" = onetime:::onetime_base_dir())


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
})


for (id in IDS) {
  suppressWarnings(onetime_reset(id))
}
rm(IDS)

options(oo)