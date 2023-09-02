
New submission to deal with a change to package documentation
(see https://github.com/r-lib/roxygen2/issues/1491). Some new
functionality is included.

Cheers,
David


## R CMD check results

* Checked on:
  - Local MacOS, R 4.3.0 OK
  - github Windows/MacOS/Linux - 1 note, package "lubridate" unavailable for checking Rd.
  - CRAN Macbuilder OK
  - CRAN Winbuilder - 1 note about moved permanently which redirected from https to http.
    I think this is a false positive. Other redirect notes were fixed.


* Winbuilder has a note about "lockfiles" being misspelt. I say this is a false
  positive. We all know what a lockfile is, and a "lock file" would sound 
  confusing.
