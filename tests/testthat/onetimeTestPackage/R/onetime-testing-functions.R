

test_onetime_do <- function (...) onetime::onetime_do(...)

test_onetime_warning <- function (...) onetime::onetime_warning(...)

test_onetime_message <- function (...) onetime::onetime_message(...)

test_onetime_echo <- function (x) onetime::onetime_do(cat(x))

test_onetime_reset <- function (...) onetime::onetime_reset(...)

cat_once <- onetime::onetime_only(cat)

test_onetime_only <- function (...) cat_once(...)
