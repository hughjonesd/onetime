

setup({
  withr::with_libpaths("onetimeTestLibrary", {
    got_external <- try(devtools::install("onetimeTestPackage",
          args = c(quiet = TRUE, verbose = FALSE)))
    skip_if(inherits(got_external, "try-error"))
    library(onetimeTestPackage)
  })
})



test_that("Calling from external package", {

  expect_output(test_onetime_echo("xxx"), "xxx")
  expect_silent(test_onetime_echo("xxx"))


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
})


teardown({
  test_onetime_reset()
  test_onetime_reset("foo")
  detach(package:onetimeTestPackage)
  withr::with_libpaths("onetimeTestLibrary", {
    remove.packages("onetimeTestPackage")
  })
})