

R_path <- file.path(R.home("bin"), "R")



test_that(".onLoad", {
  unloadNamespace(getNamespace("onetime"))
  lfd <- file.path(rappdirs::user_config_dir(), "onetime-lockfiles")
  unlink(lfd, recursive = TRUE)
  library(onetime)
  expect_true(dir.exists(lfd))
})


test_that("basic functionality", {
  ctr <- 0
  onetime_do(ctr <- ctr + 1, id = "test-id-1")
  expect_equal(ctr, 1)
  onetime_do(ctr <- ctr + 1, id = "test-id-1")
  expect_equal(ctr, 1)
  onetime_do(ctr <- ctr + 1, id = "test-id-2")
  expect_equal(ctr, 2)

  expect_warning(
          onetime_warning("foo", id = "test-id-3"),
          "foo"
        )
  expect_silent(onetime_warning("foo", id = "test-id-3"))

  expect_message(
    onetime_message("foo", id = "test-id-4"),
    "foo"
  )
  expect_silent(onetime_message("foo", id = "test-id-4"))

  expect_message(
    onetime_startup_message("foo", id = "test-id-5"),
    "foo"
  )
  expect_silent(onetime_startup_message("foo", id = "test-id-5"))
})


test_that("onetime_only", {
  cat_once <- onetime_only(cat, id = "test-id-6")
  expect_output(cat_once("foo"), "foo")
  expect_silent(cat_once("foo"))
})


test_that("onetime_reset", {
  ctr <- 0
  onetime_do(ctr <- ctr + 1, id = "test-id-7")
  expect_equal(ctr, 1)
  onetime_reset(id = "test-id-7")
  onetime_do(ctr <- ctr + 1, id = "test-id-7")
  expect_equal(ctr, 2)
})


test_that("multiprocess and command line", {
  x <- callr::r(function (...) onetime::onetime_do(1, id = "test-id-8"))
  expect_equal(x, 1)
  x <- callr::r(function (...) onetime::onetime_do(1, id = "test-id-8"))
  expect_null(x)
})

teardown({
  for (test_id in paste0("test-id-", 1:7)) {
    onetime_reset(test_id)
  }
  # reset from new process to use NO_PACKAGE directory
  x <- callr::r(function (...) onetime::onetime_reset("test-id-8"))
})