# 8.0.0
- upgraded to dcli 4.x to overcome the waitFor deprecation.

# 7.0.1
- upgraded to dart 2.18.
- Change arg parsing to ignore tags and excluded-tags when plan-name passed as the tags can be from the settings file.
- upgrade all package versions.

# 6.0.4
- fixed a null cast to non-null when processing output.

# 6.0.3
- Upgraded to dcli 1.34
- Suppressed the output of the pub get warms. We only print anything if an error occurs.
- We now output the critical test version when running.
- Added defaults to the menu selections when re-running failed tests.

# 6.0.2
- Moved displaying the legend until after the pre-hooks are run so it is displayed just above the counts.

# 6.0.1
- upgrade all packages to latest versions.

# 6.0.0
Change the defaults so that hooks are run by default. 
Change the 'hook' flag to 'no-hook'. Use --no-hook to obtain the original behaviour.
Applied lint_hard to the code base.

# 5.3.0
- upgraded to dcli 1.20.0

# 5.2.0
- change the --show flag to --all as I think the name is more evocative of the fact that it shows both error and success output.
- Added an abbreviated from of the command 'ct'. You can now run both critical_test and ct.
- Fixed a bug which caused the progress to not display.

# 5.1.3
- Fixed a bug where you couldn't use -m or -r if you had a tag, exclude-tag or plain-name in the settings.
- update transitive dependencies.

# 5.1.2
- change --hooks to default to true.

# 5.1.1
- Change the location of settings.yaml to tool/critical_test/settings.yaml so it matches the hook directory locaiton.

# 5.1.0
- Added support for ~/.critical_test/settings.yaml which allows you to set defaults for any of the command line arguments.

# 5.0.0
- Added ability to show a menu of failed tests and allow the user to select which one to run.
- Added progress messages to verbose output.
- Added command args to verbose output.
- upgraded to dcli 1.10

# 4.0.0
Major works to improve the performance of the --runfailed flag.
Pre 4.x --runfailed will re-run all tests contained in a Dart Library if even one of the tests failed.
With this release we only run the tests that failed.

The cli arguments have also changed to bring them closer to alignment with the 'dart test' command.

You can now pass a directory or script as a final argument and only tests in that directory/dart will
be ran.

```bash
critical_test [switches] [file or directory]
```
We have removed the --single switch use --plain-name instead.

We have introduced a --plain-name argument which allows you to run a single test via name.
If the test is nested with in a group(s) then you need to provide each of the group names
separated by a space.

```
critical_tests --plain-name="[<group name> <group name> ...] <test name>"
```
- hook switch abbreviation has changed from 'n' to 'o'


# 3.0.13
- had accidentially ignore analysis_options.yaml

# 3.0.11
 - Fixed a bug where the --runFailed switch was not finding any failed tests due to an inverted if statement.

# 3.0.10
Fixed the --no-hooks command line flag as it was being ignored.

# 3.0.9
Added:
 - Added code to run pub get on the package and any sub packages to ensure that the unit test run successfully from a code project. 
 - Use --no-warmup to suppress the pub get operations.
 - Added a hidden --track switch so we can use it in our own unit tests with --single so we can confirm the trackers behaviour. Fixed a unit test that was failing because single tests don't normally track.

Fixes:
 - We now corretly track failed test that occur during a rerun. Previously we would loose track of these failures.
 - re-wrote the failed tracker to try to handle aborts. Previously the list of failed tests would be lost if user used ctrl-c during a test run. We now try to preserve the failed test list.

# 3.0.8
Upgraded package versions.

# 3.0.7
upgraded to dcli 1.5.3
Fixed so unit tests find critical test on windows.

# 3.0.6
- upgraded to dcli 1.5.1
- Added test that the test directory exists.
- stripped ansi out of the count line for consistent regex matching.
- Added check that the .failed_tracker file exists rather than throwing an exception.

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
