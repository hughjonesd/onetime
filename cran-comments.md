## R CMD check results

* Checked on:
  - Local MacOS, R 4.2.0
  - github Windows/MacOS/Linux
  - Appveyor Windows

0 errors | 0 warnings | 1 note

* This is a new release.

* The onetime package uses configuration files in the user's configuration
  directory to record if code has been run. 
  
When loaded in an interactive session, it asks (one time only!) for permission 
to do this. When loaded in a non-interactive session, it tells the user that 
it's using the directory, and explains how to change the default directory 
using `options()`.

* There is a note about using `packageStartupMessage()` in `.onLoad()`.

The message warns the user that onetime stores files in the user configuration
directory, and if the session is interactive, it prompts for confirmation that
this is OK. This package is intended to be used by other package authors, not
directly, so `.onLoad()` seems more appropriate than `onAttach()`.



