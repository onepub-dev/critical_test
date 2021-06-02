# 3.0.3
Upgraded to dcli 1.5.0

Fixed a number of unit tests.

# 3.0.2
Added support for running dart scripts for hooks on windows and if dcli not installed.

# 3.0.1
Fixed a bug where we used the critical_tests project root rather than the target projects root to find hooks.

# 3.0.0
Simplified the hook path names and made them more consistent.
the hook paths are now:

tool/critical_test/pre_hook
tool/critical_test/post_hook

Added warning if a non-executable hook file is detected.


# 2.0.1
Fix: Fixed a bug with the path to failed tests .failed_tracker. The path had test/test/ as a prefix
rather than just test/
Attempt to improve the error handling if one of the spawned commands fails.

# 2.0.0
Change the flag --logTo to --logPath.
Changed the exit codes to conform close to what other packages use. 0 - is good, 1 is bad, 5 no test were ran.
Added new command line arg --[no]-progress to improve the CI pipeline experience.

# 1.0.8
Fixed bug where the skipped count was reporting 0 when tests had been skipped. 
Added unit tests to check the counts. 
Attempts to improve the coverage support but still not writting to the correct directory. 
If the shelled unit tests fail to start we now print the error output.
Fixed counting problems by checking for the hidden flag.
Corrected the syntax of the tag argumetnts when passed to the test package.
Fixed a bug where exclude-tags flag was passing the arg into the wrong variable.
Cleaned up the messages. Now logs the package name we are running tests for.
Added tags and exclude-tags command line options to allow control over what tests are run.

# 1.0.7
the critical test application now returns -1 if any tests failed.
Added hidden verbose flag to make diagnostics easier.

# 1.0.6
Fixed a bug caused when a child process is spawned which directly prints to stdout. We now strip this out of the json messages to stop json decode problems.

# 1.0.5
Improvements to the readme.

# 1.0.4
Changed the run_failed switch to runfailed.
spelling in the readme.

# 1.0.3
Minor cleanup on the readme.

# 1.0.2
renamed flag --run_failed to --runfailed
Fixed a counting problem on the error logs when failures and errors occure.

# 1.0.1
Added noojee logo.

# 1.0.0
First release of critical test.
