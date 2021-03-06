# README

## Critical Test

Critical Test is a cli tool designed to provide an enhanced cli experience when running Dart unit tests.

Fixing broken unit tests is an ongoing job in any active project. Whilst it is usually better to run your unit tests from within your IDE, in some circumstances this isn't possible or convenient.

Critical Test runs your unit tests from the cli and makes it easy to identify broken tests and re-run those tests.

By default Critical Test suppresses the output of any tests that succeed so you can focus on those critical failed test.

Critical Test then lets you re-run individual failed tests or re-run all failed tests.

Critical Tests also provides an enhanced view of failed unit tests making it easier to review those tests.

## Another Dart tool by Noojee

![Noojee](images/noojee-logo.png)

## Run all tests

To run all tests simply run `critical_test` from the root of you project.

```bash
dart pub global activate critical_test
cd <your project root>
critcal_test
```

## Run a single test

If a test fails, Critical Test outputs instructions on how to re-run that single test.

You will see a blue line just above the 'END ERROR' line with the instructions.

```
package:test_api           fail
test/test2_test.dart 13:7  main.<fn>.<fn>

Rerun test via: critical_test --single=test/test2_test.dart
******************************** END ERROR (2) *********************************
6:2:0:0 test2_test.dart: Tests completed with some failures
```

To re-run the failed test:

`critical_test --single=test/test2_test.dart`

## Re-run all failed tests

Each time you do a test run (except when --single is used) Critical Test tracks each of the failed tests.

You can re-run just the failed tests by running:

`critical_test --runfailed`

## exit codes

You can check how the test ran via the critical test exit code.

0 - all tests passed 1 - some tests failed 5 - no tests were run

### progress

The --\[no]-progress flag allows you to control whether the progress messages are output.

By default progress messages are displayed.

When using Critical Test in a CI pipeline we recommend running with --no-progress as this reduces the amount of clutter in your CI's logs.

In this mode you will only get a small intro message and a completion message. If any errors are generated they are still logged to the console in full.

### show

When Critical Test runs it normally suppresses the output of any tests that succeed.

You can use the `--show` command line switch to run the test showing output from both failed and successful tests.

`critical_test --show`

### Selecting tests to run

Critical Test takes two commandline arguments that allow you to control which tests are run:

* \--tags=`<tag expression>`
* \--exclude-tags=`<tag expression>`

Both of these flags are passed directly to the unit test package and so must conform to the documented [tag expression](https://pub.dev/packages/test#tagging-tests) syntax.

e.g. --tags="(chrome || firefox) && !slow" --exclude-tags=slow

### logPath

By default critical\_tests logs both successful and failed tests to `<system temp dir>/critical_test/unit_tests.log`.

You can modify the file the unit tests are logged to via:

`critical_test --logPath=<somepath>`

## Monitoring progress

Critical Test provides a single updating line that shows progress of the unit tests.

```
    2:1:0:0 test_test.dart: Loading
```

The firsts four numbers in order are:

* Successes - shown in green
* Failures - shown in orange
* Errors - shown in red
* Skipped - shown in blue

You can also monitor the full output of the unit tests (including successful unit tests) by tailing the log file:

`tail -f /<system temp dir>/critical_test/unit_tests.log`

## Pre/Post test hooks.

When running unit tests you may need to do some preparatory and/or cleanup work.

Ideally this should be in the `setupAll` and `tearDownAll` methods in your unit tests.

If that isn't possible then Critical Test allows you to specify hooks that are run before and after the unit tests are run.

The Critical Test hooks are particularly useful for starting/stopping services (a database, docker container etc) before/after you run your unit tests.

A hook can be any executable such as a DCli or Bash script.

To create a hook, create a critical\_test directory under your project's 'tool' directory

`tool\critical_test`

`pre_hooks` are run before the unit tests start. `post`\_`hooks` are run after all unit tests have completed.

Pre/Post hooks will also run when you use the --single switch.

You can suppress hooks by passing in the --no-hooks flag.

```bash
cd <myproject>/tool
mkdir critical_test
mkdir critical_test/pre_hook
mkdir critical_test/post_hook
touch critical_test/pre_hook/dostuff.sh
chmod +x critical_test/pre_hook/dostuff.sh
```

Hooks are sorted alphanumerically so you can prefix the hook's name with a number if you need to control the order the hooks run in.

## Settings.yaml

Critical Test allows you to provide default values for any of the command line arguments by creating a settings.yaml file in the tool/critical\_test directory.&#x20;

To set a default for a command line argument use the same name in the settings file:

\<project root>/tool/critical\_test/settings.yaml

```
tags: ['backend','frontend']
log-path: /tmp/log.tmp
```

## DCli

Critical Test was written in Dart using [DCli](https://pub.dev/packages/dcli) to support the [Conduit](https://pub.dev/packages/conduit) project.
