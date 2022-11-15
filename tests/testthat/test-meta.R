test_that("check_ok_to_store", {

  suppressWarnings(onetime_reset("ok-to-store", onetime:::onetime_base_dir("")))

  withr::with_options(list(onetime.dir = NULL), {
    expect_false(
      check_ok_to_store()
    )
  })

  withr::with_options(list(onetime.dir = onetime:::onetime_base_dir()), {
    expect_true(
      check_ok_to_store()
    )
  })
})


test_that("ask_ok_to_store", {
  if(! interactive()) {
    mockr::local_mock(
      my_interactive = function () TRUE,
      my_readline = function (...) INPUT
    )
  }

  if (interactive()) message("Please enter n at the next prompt")
  INPUT <- "n"
  expect_message(
    res <- check_ok_to_store(ask = TRUE)
  )
  expect_false(res)

  INPUT <- "n"
  expect_message(
    res <- ask_ok_to_store(message = "Dir %s, Enter n ",
                           confirm_prompt = "Please enter n ")
  )
  expect_false(res)
  expect_false(
    check_ok_to_store()
  )

  INPUT <- "y"
  ask_ok_to_store(message = "Dir %s, Enter y ",
                  confirm_prompt = "Please enter y ")
  expect_silent(
    res <- check_ok_to_store()
  )
  expect_true(res)
})