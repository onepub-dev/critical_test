# Overview

## Critical Test

Critical Test is a cli tool designed to provide an enhanced cli experience when running Dart unit tests.

Fixing broken unit tests is an ongoing job in any active project. Whilst it is usually better to run your unit tests from within your IDE, in some circumstances this isn't possible or convenient.

Critical Test is designed to allow you to do casual unit testing as well as being a part of your release process.

{% hint style="info" %}
For full automation of your release process from the cli, see [pub\_release](https://pub.dev/packages/pub_release) which works with critical test
{% endhint %}

Critical Test runs your unit tests from the cli and makes it easy to identify broken tests and re-run those tests.

By default Critical Test suppresses the output of any tests that succeed so you can focus on those critical failed test.

Critical Test then lets you re-run individual failed tests or re-run all failed tests.

Critical Tests also provides an enhanced view of failed unit tests making it easier to review those tests.

## Another Dart tool by Noojee

![Noojee](https://github.com/bsutton/critical_test/blob/main/images/noojee-logo.png?raw=true)

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

```text
package:test_api           fail
test/test2_test.dart 13:7  main.<fn>.<fn>

Rerun test via: critical_test --single=test/test2_test.dart
******************************** END ERROR (2) *********************************
6:2:0:0 test2_test.dart: Tests completed with some failures
```

To re-run the failed test:

```text
critical_test --single=test/test2_test.dart
```

## Re-run all failed tests

Each time you do a test run \(except when --single is used\) Critical Test tracks each of the failed tests.

You can re-run just the failed tests by running:

```text
critical_test --runfailed
```

### show

When Critical Test runs it normally suppresses the output of any tests that succeed.

You can use the `--show` switch to run the tests showing output from both failed and successful tests.

```text
critical_test --show
```

### Selecting tests to run

Critical Test takes two command line arguments that allow you to control which tests are run:

* --tags=`<tag expression>`
* --exclude-tags=`<tag expression>`

Both of these flags are passed directly to the unit test package and so must conform to the documented [tag expression](https://pub.dev/packages/test#tagging-tests) syntax.

```text
critical_test --tags="(chrome || firefox) && !slow" --exclude-tags=db_required
```

### logTo

By default critical\_tests logs both successful and failed tests to `<system temp dir>/critical_test/unit_tests.log`.

You can modify the file the unit tests are logged to via:

```text
critical_test --logTo=<somepath>
```

## Monitoring progress

Critical Test provides a single updating line that shows progress of the unit tests.

```text
    2:1:0:0 test_test.dart: Loading
```

The firsts four numbers in order are:

* Successes - shown in green
* Failures - shown in orange
* Errors - shown in red
* Skipped - shown in blue

You can also monitor the full output of the unit tests \(including successful unit tests\) by tailing the log file:

`tail -f /<system temp dir>/critical_test/unit_tests.log`

## Pre/Post test hooks.

When running unit tests you may need to do some preparatory and/or cleanup work.

Ideally this should be in the `setupAll` and `tearDownAll` methods in your unit tests.

If that isn't possible then Critical Test allows you to specify hooks that are run before and after the unit tests are run.

The Critical Test hooks are particularly useful for starting/stopping services \(a database, docker container etc\) before/after you run your unit tests.

A hook can be any executable such as a [DCli](https://pub.dev/packages/dcli) or Bash script.

To create a hook, create a critical\_test\_hook directory under your project's 'tool' directory

pre-hooks are run before the unit tests start. post-hooks are run after all unit tests have completed.

Pre/Post hooks will also run when you use the --single switch.

You can suppress hooks by passing in the --no-hooks flag.

```bash
cd <myproject>
mkdir tool/critical_test_hook
mkdir tool/critical_test_hook/pre-hook
mkdir tool/critical_test_hook/post-hook
touch tool/critical_test_hook/pre-hook/start_db.dart
chmod +x tool/critical_test_hook/pre-hook/start_db.dart
```

Hooks are sorted alphanumerically so you can prefix the hook's name with a number if you need to control the order the hooks run in.

## DCli

Critical Test was written in Dart using [DCli](https://pub.dev/packages/dcli) to support the [Conduit](https://pub.dev/packages/conduit) project.

