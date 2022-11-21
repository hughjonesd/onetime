

IDS <- character(0)

test_id <- function (id) {
  id <- paste0("basic-", id)
  IDS <<- c(IDS, id)
  IDS <<- unique(IDS)
  return(id)
}

oo <- options(onetime.dir = tempdir(check = TRUE))


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


test_that("onetime_been_done", {
  id <- test_id("test-id-been-done")
  expect_false(
    onetime_been_done(id = id)
  )
  onetime_do(1+1,  id = id)
  expect_true(
    onetime_been_done(id = id)
  )

  expiry <- as.difftime(1, units = "secs")
  Sys.sleep(2)
  expect_false(
    onetime_been_done(id = id, expiry = expiry)
  )
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


test_that("without_permission", {
  mockr::with_mock(
    check_ok_to_store = function(...) FALSE,
    {
      expect_equal(
        onetime_do(1L, without_permission = "run", id = test_id("wp1")),
        1L
      )
      expect_warning(
        onetime_do(1L, without_permission = "warn", id = test_id("wp2"))
      )
      expect_equal(
        onetime_do(1L, without_permission = "pass", default = 0,
                   id = test_id("wp3")),
        0L
      )
      expect_error(
        onetime_do(1L, without_permission = "stop", id = test_id("wp4"))
      )
    }
  )

  suppressWarnings(set_ok_to_store(FALSE))
  withr::defer(suppressWarnings(set_ok_to_store(TRUE)))

  if (interactive()) {
    print("Please say n next")
  } else {
    mockr::local_mock(
      check_ok_to_store = function(...) FALSE
    )
  }

  expect_equal(
    onetime_do(1L, without_permission = "ask", default = 0L,
               id = test_id("wp5")),
    0L
  )

  if (interactive()) {
    print("Please say y next")
  } else {
    mockr::local_mock(
      check_ok_to_store = function(...) TRUE
    )
  }
  expect_equal(
    onetime_do(1L, without_permission = "ask", default = 0L,
               id = test_id("wp6")),
    1L
  )
})


test_that("multiprocess", {
  withr::defer({
    # reset from external process to use NO_PACKAGE directory
    callr::r(function (...) onetime::onetime_reset("test-id-mp"))
  })

  x <- callr::r(function (...) {
      withr::with_options(list(onetime.dir = onetime:::onetime_base_dir()), {
        onetime::onetime_do(1, id = "test-id-mp")
    })
  })
  expect_equal(x, 1)

  x <- callr::r(function (...) {
      withr::with_options(list(onetime.dir = onetime:::onetime_base_dir()), {
        onetime::onetime_do(1, id = "test-id-mp")
    })
  })
  expect_null(x)
})


for (id in IDS) {
  suppressWarnings(onetime_reset(id))
}
rm(IDS)
options(oo)
