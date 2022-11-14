

setup({
  withr::with_libpaths("onetimeTestLibrary", {
    got_external <- try(devtools::install("onetimeTestPackage", quiet = TRUE))
    skip_if(inherits(got_external, "try-error"))
    library(onetimeTestPackage)
  })
})

oo <- options("onetime.ok_to_store" = TRUE)


test_that("Calling from external package", {
  expect_output(test_onetime_echo("xxx"), "xxx")
  expect_silent(test_onetime_echo("xxx"))
  test_onetime_reset()

  ctr <- 0
  test_onetime_do(ctr <- ctr + 1, id = "foo")
  expect_equal(ctr, 1)
  test_onetime_do(ctr <- ctr + 1, id = "foo")
  expect_equal(ctr, 1)
  test_onetime_reset("foo")

  test_onetime_do(ctr <- ctr + 1, id = "foo")
  expect_equal(ctr, 2)
  test_onetime_do(ctr <- ctr + 1, id = "foo")
  expect_equal(ctr, 2)
  test_onetime_reset("foo")
})

test_that("onetime_warning/message from external", {
  expect_warning((test_onetime_warning("foo")), "foo")
  expect_silent((test_onetime_warning("foo")))
  test_onetime_reset()

  expect_message((test_onetime_message("foo")), "foo")
  expect_silent((test_onetime_message("foo")))
  test_onetime_reset()

  expect_message((test_onetime_startup_message("foo")), "foo")
  expect_silent((test_onetime_startup_message("foo")))
  test_onetime_reset()
})

test_that("onetime_only from external", {
  expect_output(test_onetime_only("foo"), "foo")
  expect_silent(test_onetime_only("foo"))
  test_onetime_reset()

  expect_output(test_onetime_only("foo"), "foo")
  test_onetime_reset()
})

options(oo)

teardown({
  detach(package:onetimeTestPackage)
  withr::with_libpaths("onetimeTestLibrary", {
    suppressMessages(remove.packages("onetimeTestPackage"))
  })
})