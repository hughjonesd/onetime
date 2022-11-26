# onetime (development version)

* New function `onetime_mark_as_done()` to manually mark an action as done.

* `onetime_message_confirm()` now prints its message by default in 
  non-interactive sessions, along with instructions on how to hide the message 
  using `onetime_mark_as_done()`.
  
* `onetime_message_confirm()` now passes multiple arguments to `message()` 
  using `...`. Using a named `message` argument is soft-deprecated.

# onetime 0.1.0

* Initial release.
