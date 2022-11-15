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
  skip_if(! interactive())
  ask_ok_to_store(msg = "Dir %s, Enter y ", confirm_prompt = "Please enter y ")
  expect_true(
    check_ok_to_store()
  )
})