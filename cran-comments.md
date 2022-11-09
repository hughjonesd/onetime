## R CMD check results

* Checked on:
  - Local MacOS, R 4.2.0
  - github Windows/MacOS/Linux
  - Appveyor Windows

0 errors | 0 warnings | 0 notes

* This is a new release.

* The onetime package uses configuration files in the user's configuration
  directory to record if code has been run. 
  
When loaded in an interactive session, it asks (one time only!) for permission 
to do this. When loaded in a non-interactive session, it tells the user that 
it's using the directory, and explains how to change the default directory 
using `options()`.

This package is intended to be used by other package authors, not by users 
directly, so `.onLoad()` seems more appropriate than `onAttach()`.



