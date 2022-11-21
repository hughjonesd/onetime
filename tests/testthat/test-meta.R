
test_that("set_ok_to_store", {
  oo <- options(onetime.dir = tempdir(check = TRUE))
  withr::defer({
    options(oo)
  })

  suppressWarnings(set_ok_to_store(TRUE))
  expect_message(set_ok_to_store(FALSE))
  expect_null(getOption("onetime.dir"))
  oo <- options(onetime.dir = tempdir(check = TRUE))
  expect_message(set_ok_to_store(TRUE), "set_ok_to_store")
})


test_that("check_ok_to_store(ask = FALSE)", {
  skip_on_cran()
  suppressWarnings(set_ok_to_store(FALSE))
  withr::defer({
    oo <- options(onetime.dir = tempdir(check = TRUE))
  })

  withr::with_options(list(onetime.dir = NULL), {
    expect_false(
      check_ok_to_store(ask = FALSE)
    )
  })

  withr::with_options(list(onetime.dir = onetime:::onetime_base_dir()), {
    expect_true(
      check_ok_to_store(ask = FALSE)
    )
  })
})


test_that("check_ok_to_store(ask = TRUE)", {
  if(! interactive()) {
    mockr::local_mock(
      my_interactive = function () TRUE,
      my_readline = function (...) INPUT
    )
  }

  suppressWarnings(set_ok_to_store(FALSE))
  withr::defer({
    suppressWarnings(set_ok_to_store(TRUE))
  })

  if (interactive()) {
    expect_message(
      res <- check_ok_to_store(ask = TRUE, confirm_prompt = "Please enter n ")
    )
  } else {
    INPUT <- "n"
    res <- check_ok_to_store(ask = TRUE)
  }
  expect_false(res)

  expect_false(
    check_ok_to_store(ask = FALSE)
  )

  INPUT <- "y"
  check_ok_to_store(ask = TRUE, confirm_prompt = "Please enter y ")
  expect_silent(
    res <- check_ok_to_store(ask = FALSE)
  )
  expect_true(res)
})