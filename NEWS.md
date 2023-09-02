# onetime 0.2.0

* Not setting `id` explicitly is now deprecated with a warning. Doing this
  is brittle: it can lead to silent errors when you use onetime functions 
  in more than one place.
  
* New function `onetime_mark_as_done()` to manually mark an action as done.

* New function `onetime_dir("dirname")` returns a path to an arbitrary 
  subdirectory of the onetime base directory for lockfiles.

* `onetime_message_confirm()` now prints its message by default in 
  non-interactive sessions, along with instructions on how to hide the message 
  using `onetime_mark_as_done()`.
  
* `onetime_message_confirm()` now passes multiple arguments to `message()` 
  using `...`. This makes it easier to pass long messages.
  Using a named `message` argument is soft-deprecated.

* `onetime_only()` gains a `default` argument which is returned by the
  wrapper function if the inner function was not called. The default `default`
  is `NULL`.

* `onetime_message()` and friends all now return their results invisibly. This 
  is nicer for use in rmarkdown documents.
  
* `onetime_do()` now always returns invisibly, even when `default` is returned.

* `onetime_only()` now respects the visibility of the wrapped function.

* New vignette.
  
# onetime 0.1.0

* Initial release.
