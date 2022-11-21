

test_onetime_do <- function (...) onetime::onetime_do(...)

test_onetime_warning <- function (...) onetime::onetime_warning(...)

test_onetime_message <- function (...) onetime::onetime_message(...)

test_onetime_startup_message <- function (...) onetime::onetime_startup_message(...)

test_onetime_echo <- function (x) onetime::onetime_do(message(x))

test_onetime_reset <- function (...) onetime::onetime_reset(...)

test_onetime_only <- function (...) {
  onetime::onetime_only(message)
}

