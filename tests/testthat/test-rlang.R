

IDS <- character(0)

test_id <- function (id) {
  id <- paste0("rlang-", id)
  IDS <<- c(IDS, id)
  IDS <<- unique(IDS)
  return(id)
}

oo <- options("onetime.ok_to_store" = TRUE)


test_that("onetime_rlang_warn", {
    expect_warning(
          rv <- onetime_rlang_warn("foo", id = test_id("test-id-1")),
          "foo"
        )
  expect_true(rv)
  expect_silent(rv <- onetime_rlang_warn("foo", id = test_id("test-id-1")))
  expect_false(rv)
})


test_that("onetime_rlang_inform", {
  expect_message(
          rv <- onetime_rlang_inform("foo", id = test_id("test-id-2")),
          "foo"
        )
  expect_true(rv)
  expect_silent(rv <- onetime_rlang_inform("foo", id = test_id("test-id-2")))
  expect_false(rv)
})


test_that("Fallbacks", {
  mockr::local_mock(
    require_rlang = function() FALSE
  )

  expect_message(
          rv <- onetime_rlang_inform("foo", id = test_id("test-id-3")),
          "rlang"
        )
  expect_true(rv)
  expect_message(
          rv <- onetime_rlang_inform("foo", id = test_id("test-id-4")),
          "rlang"
        )
  expect_true(rv)
})



teardown({
  for (id in IDS) {
    suppressWarnings(onetime_reset(id))
  }
  rm(IDS)

  options(oo)
})
