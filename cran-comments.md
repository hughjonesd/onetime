## R CMD check results

* Checked on:
  - Local MacOS, R 4.2.0
  - github Windows/MacOS/Linux
  - Appveyor Windows
  - CRAN Macbuilder
  - CRAN Winbuilder

0 errors | 0 warnings | 0 notes

* Winbuilder has a note about "lockfiles" being misspelt. I say this is a false
  positive. We all know what a lockfile is, and a "lock file" would sound 
  confusing.
  
* This is a new release.

The onetime package is designed for package authors to perform actions or show
messages once only (ever). It uses lockfiles in the user's
configuration directory to record if code has been run. Files won't be
stored unless the user has given permission; package authors are encouraged
to call `check_ok_to_store(ask = TRUE)` in an interactive session, which
asks for permission to store lockfiles. 


