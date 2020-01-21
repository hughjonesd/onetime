

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
})


test_that("onetime_only", {
  cat_once <- onetime_only(cat, id = "test-id-5")
  expect_output(cat_once("foo"), "foo")
  expect_silent(cat_once("foo"))
})


test_that("onetime_reset", {
  ctr <- 0
  onetime_do(ctr <- ctr + 1, id = "test-id-6")
  expect_equal(ctr, 1)
  onetime_reset(id = "test-id-6")
  onetime_do(ctr <- ctr + 1, id = "test-id-6")
  expect_equal(ctr, 2)
})


test_that("multiprocess and command line", {
  x <- system2("R", c("-q", "-e",
        "'onetime::onetime_do(cat(\"foo\\n\"), id = \"test-id-7\")'"),
        stdout = TRUE
      )
  expect_match(x, "^foo$", perl = TRUE, all = FALSE)

  x <- system2("R", c("-q", "-e",
          "'onetime::onetime_do(cat(\"foo\\n\"), id = \"test-id-7\")'"),
          stdout = TRUE
        )
  expect_false(any(grepl("^foo$", x, perl = TRUE)))
})

teardown({
  for (test_id in paste0("test-id-", 1:6)) {
    onetime_reset(test_id)
  }
  system2("R", c("-q", "-e", "'onetime::onetime_reset(id = \"test-id-7\")'"),
        stdout = FALSE)
})