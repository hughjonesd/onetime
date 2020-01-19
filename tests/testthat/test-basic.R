

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


test_that("onetime_reset", {
  ctr <- 0
  onetime_do(ctr <- ctr + 1, id = "test-id-5")
  expect_equal(ctr, 1)
  onetime_reset(id = "test-id-5")
  onetime_do(ctr <- ctr + 1, id = "test-id-5")
  expect_equal(ctr, 2)
})


teardown({
  for (test_id in paste0("test-id-", 1:5)) {
    onetime_reset(test_id)
  }
})