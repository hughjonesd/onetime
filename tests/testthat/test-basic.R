

R_path <- file.path(R.home("bin"), "R")

IDS <- character(0)

test_id <- function (id) {
  IDS <<- c(IDS, id)
  IDS <<- unique(IDS)
  return(id)
}

test_that(".onLoad", {

  # unloadNamespace(getNamespace("onetime"))
  detach(package:onetime, unload = TRUE)
  if (isNamespaceLoaded("onetime")) {
    skip("Couldn't unload onetime namespace")
  }

  withr::local_options(onetime.dir = NULL)
  # don't use onetime_base_dir(), that will prematurely reload the namespace!
  obd <- file.path(rappdirs::user_config_dir(), "onetime-lockfiles")
  unlink(obd, recursive = TRUE)
  basic_confirmation_file <- file.path(rappdirs::user_config_dir(),
                                       "onetime-basic-confirmation")
  unlink(basic_confirmation_file)

  if (interactive()) {
    loadNamespace("onetime")
  } else {
    expect_message(loadNamespace("onetime"))
  }

  expect_true(dir.exists(obd))
  library(onetime)
})


test_that("onetime_do", {
  ctr <- 0
  onetime_do(ctr <- ctr + 1, id = test_id("test-id-1"))
  expect_equal(ctr, 1)
  onetime_do(ctr <- ctr + 1, id = test_id("test-id-1"))
  expect_equal(ctr, 1)
  onetime_do(ctr <- ctr + 1, id = test_id("test-id-2"))
  expect_equal(ctr, 2)

  a <- onetime_do(1+1, id = test_id("test-id-2.5"))
  expect_equal(a, 2)
  b <- onetime_do(1+1, id = test_id("test-id-2.5"))
  expect_null(b)
  d <- onetime_do(1+1, id = test_id("test-id-2.5"), default = 3)
  expect_equal(d, 3)
})


test_that("onetime_warning/message/startup_message", {
  expect_warning(
          onetime_warning("foo", id = test_id("test-id-3")),
          "foo"
        )
  expect_silent(onetime_warning("foo", id = test_id("test-id-3")))

  expect_message(
    onetime_message("foo", id = test_id("test-id-4")),
    "foo"
  )
  expect_silent(onetime_message("foo", id = test_id("test-id-4")))

  expect_message(
    onetime_startup_message("foo", id = test_id("test-id-5")),
    "foo"
  )
  expect_silent(onetime_startup_message("foo", id = test_id("test-id-5")))
})


test_that("onetime_message_confirm", {
  if (! interactive()) {
    skip("Test needs interaction: run `devtools::test()` from the command line.")
  } else {
    expect_message(
      onetime_message_confirm("Say Y",
                              confirm_prompt = "Please say Y",
                              id = test_id("test-id-omc"))
    )
    expect_message(
      onetime_message_confirm("Say N",
                              confirm_prompt = "Now say N",
                              id = test_id("test-id-omc"))
    )
    expect_silent(
      onetime_message_confirm("Should be hidden", id = test_id("test-id-omc"))
    )
  }
})


test_that("onetime_only", {
  cat_once <- onetime_only(cat, id = test_id("test-id-6"))
  expect_output(cat_once("foo"), "foo")
  expect_silent(cat_once("foo"))
})


test_that("onetime_reset", {
  ctr <- 0
  onetime_do(ctr <- ctr + 1, id = test_id("test-id-7"))
  expect_equal(ctr, 1)
  onetime_reset(id = test_id("test-id-7"))
  onetime_do(ctr <- ctr + 1, id = test_id("test-id-7"))
  expect_equal(ctr, 2)
})


test_that("expiry", {
  expiry <- as.difftime(1, units = "secs")
  expect_message(
    onetime_message("Not expired", id = test_id("expiry"), expiry = expiry)
  )
  expect_silent(
    onetime_message("Not expired", id = test_id("expiry"), expiry = expiry)
  )
  Sys.sleep(2)
  expect_message(
    onetime_message("Not expired", id = test_id("expiry"), expiry = expiry)
  )
})


test_that("multiprocess", {
  myid <- test_id("test-id-8")
  x <- callr::r(function (...) onetime::onetime_do(1, id = "test-id-8"))
  expect_equal(x, 1)
  x <- callr::r(function (...) onetime::onetime_do(1, id = "test-id-8"))
  expect_null(x)
})


teardown({
  for (test_id in IDS) {
    suppressWarnings(onetime_reset(test_id))
  }
  # reset from new process to use NO_PACKAGE directory
  x <- callr::r(function (...) onetime::onetime_reset("test-id-8"))
})