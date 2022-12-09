



skip_on_cran()
oo <- options(onetime.dir = tempdir(check = TRUE))
withr::with_libpaths("onetimeTestLibrary", {
  got_external <- try(devtools::install("onetimeTestPackage", quiet = TRUE))
  skip_if(inherits(got_external, "try-error"))
  library(onetimeTestPackage)
})


test_that("onetime_do warns if no id given", {
  lifecycle::expect_deprecated(
    test_onetime_do(1 + 1)
  )
  test_onetime_reset()
})


test_that("onetime_only from external", {
  m <- test_onetime_only()
  expect_message(m("foo"), "foo")
  expect_silent(m("bar"))
  test_onetime_reset()
})


test_that("Calling from external package", {
  oo <- options(onetime.dir = tempdir(check = TRUE))
  expect_message(test_onetime_echo("xxx"), "xxx")
  expect_output(test_onetime_echo("xxx"), NA)
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
  oo <- options(onetime.dir = tempdir(check = TRUE))
  expect_warning(test_onetime_warning("foo"), "foo")
  expect_output(test_onetime_warning("foo"), NA)
  test_onetime_reset()

  expect_message(test_onetime_message("foo"), "foo")
  expect_output(test_onetime_message("foo"), NA)
  test_onetime_reset()

  expect_message(test_onetime_startup_message("foo"), "foo")
  expect_output(test_onetime_startup_message("foo"), NA)
  test_onetime_reset()
})

options(oo)
detach(package:onetimeTestPackage)
withr::with_libpaths("onetimeTestLibrary", {
  suppressMessages(remove.packages("onetimeTestPackage"))
})
