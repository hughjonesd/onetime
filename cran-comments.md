
Resubmission after manual review. Responses to review are below:

    \dontrun{} should only be used if the example really cannot be executed
    (e.g. because of missing additional software, missing API keys, ...) by
    the user. That's why wrapping examples in \dontrun{} adds the comment
    ("# Not run:") as a warning for the user.
    Does not seem necessary.


Done. I've kept one dontrun section in set_ok_to_store(), which alters
the user's preferences and writes a file.


    You write information messages to the console that cannot be easily
    suppressed. It is more R like to generate objects that can be used to
    extract the information a user is interested in, and then print() that
    object.
    Instead of print()/cat() rather use message()/warning()  or
    if(verbose)cat(..) (or maybe stop()) if you really have to write text to
    the console.
    (except for print, summary, interactive functions)
    e.g.: tests/testthat/test-basic.R


I use cat() in tests because testthat suppresses message().
cat() is only used when testing in interactive mode, when I (or the user)
needs to know how to respond. If I don't use print or cat, then users
won't be able to test the package interactively. cat() will never be used outside
of interactive mode (e.g. in R CMD CHECK).

I've replaced cat in examples with message() or other functions.
I've kept it in README.Rmd, where it prints to the resulting markdown file
and into package documentation.


    Please ensure that your functions do not write by default or in your
    examples/vignettes/tests in the user's home filespace (including the
    package directory and getwd()). This is not allowed by CRAN policies.
    Please omit any default path in writing functions. In your
    examples/vignettes/tests you can write to tempdir().


I now use tempdir() in tests, the README and examples.


    Please do not install packages in your functions, examples or vignette.
    This can make the functions,examples and cran-check very slow.


Testing from an external package is important for me. I now skip this test on
CRAN, so it won't burden CRAN servers. Is that OK? 

Cheers,
David


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


