

IDS <- character(0)

test_id <- function (id) {
  id <- paste0("rlang-", id)
  IDS <<- c(IDS, id)
  IDS <<- unique(IDS)
  return(id)
}

oo <- options(onetime.dir = tempdir(check = TRUE))

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


for (id in IDS) {
  suppressWarnings(onetime_reset(id))
}
rm(IDS)

options(oo)

