# Critical Test

Critical Test is a cli tool designed to provide an enhanced cli experience when running Dart unit tests.

Fixing broken unit tests is an ongoing job in any active project.

Whilst it is usually better to run your unit tests from within your IDE, in some circumstances this isn't possible or convenient.

Critical Test runs your unit tests from the cli and makes it easy to identify broken tests and re-run those tests.

By default Critical Test suppresses the output of any tests that succeed so you can focus on the failed test.

Critical Test then lets you run-run individual failed tests or re-run all failed tests.

Critical Tests also provides an enhanced view of failed unit tests making it easier to review those tests.

# Another Dart tool by Noojee

![Noojee](https://github.com/bsutton/critical_test/blob/main/images/noojee-logo.png?raw=true)


# Run a single test

If a test fails, Critical Test outputs instructions on how to re-run that single test.

You will see a blue line just above the 'END ERROR' line with the instructions.

```bash
package:test_api           fail
test/test2_test.dart 13:7  main.<fn>.<fn>

Rerun test via: critical_test --single=test/test2_test.dart
******************************** END ERROR (2) *********************************
6:2:0:0 test2_test.dart: Tests completed with some failures
```

To re-run the failed test:

critical_test --single=test/test2_test.dart

# Re-run all failed tests
Each time you do a test run (except when --single is used) Critical Test tracks each of the failed tests.

You can re-run just the failed tests by running:

```bash
critical_test --runfailed
```

## show

When Critical Test runs it normally suppresses the output of any tests that succeed.

You can use the `--show` command line switch to run the test showing output from both failed and successful tests.

```bash
critical_test --show
```


## logTo

By default critical_tests logs both successful and failed tests to <system temp dir>/critical_test/unit_tests.log

You can modify the file the unit tests are logged to via:

```bash
critical_test --logTo=<somepath>
```

# Monitoring progress

Critical Test provides a single updating line that shows progress of the unit tests.
```
    2:1:0:0 test_test.dart: Loading
```

The firsts four numbers in order are:

Successes - show in green
Failures - show in orange
Errors - show in red
Skipped - show in blue

You can also monitor the full output of the unit tests (including successful unit tests) by tailing the log file:

```bash
tail  -f /<system temp dir>/critical_test/unit_tests.log
```

# Pre/Post test hooks.

When running unit tests you may need to do some preparatory and/or cleanup work when running the unit tests.

Ideally this should be in the `setupAll` and `tearDownAll` methods in your unit tests.

If that isn't possible then Critical Test allows you to specify hooks that are run 
before and after the unit tests are run.

A hook can be any executable such as a DCli or bash script.

To create a hook, create a critical_test_hook directory under your project's 'tool' directory

pre-hooks are run before the unit tests start.
post-hooks are run after all unit tests have completed.

Pre/Post hooks will also run when you use the --single switch.

You can suppress hooks by passing in the --no-hooks flag.

```bash
cd <myproject>/tool
mkdir critical_test_hook
mkdir critical_test_hook/pre-hook
mkdir critical_test_hook/post-hook
touch critical_test_hook/pre-hook/dostuff.sh
chmod +x critical_test_hook/pre-hook/dostuff.sh
```

Hooks are sorted alphanumerically so you can prefix the hook's name with a number if you need to control the order the hooks run in.


