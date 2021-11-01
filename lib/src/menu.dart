import 'dart:io';

import 'package:critical_test/src/process_output.dart';
import 'package:critical_test/src/run.dart';
import 'package:critical_test/src/unit_tests/unit_test.dart';
import 'package:dcli/dcli.dart';

import 'unit_tests/failed_tracker.dart';

void testMenu({
  required ProcessOutput processor,
  required String pathToProjectRoot,
  required bool coverage,
  required bool warmup,
  required bool track,
  required bool hooks,
  required String trackerFilename,
}) {
  final tracker = FailedTracker.beginReplay(trackerFilename);

  final failedTests = tracker.failedTests.toList();

  if (failedTests.isEmpty) {
    print(green('All tests have passed. Nothing to run.'));
    exit(0);
  }

  var action = 'back';
  do {
    print(green('Select the test to view'));
    final selected = menu<UnitTest>(
        prompt: 'Select Test:',
        options: [...failedTests, const UnitTest.exitOption()],
        format: (unitTest) => unitTest.testName);

    if (selected == const UnitTest.exitOption()) {
      exit(0);
    }
    print(selected);
    final action = menu(prompt: 'Action: ', options: ['run', 'back']);

    if (action == 'run') {
      print('Running: $selected');
      runSingleTest(
          processor: processor,
          pathToProjectRoot: pathToProjectRoot,
          pathTo: selected.pathTo,
          testName: selected.testName,
          tags: null,
          excludeTags: null,
          coverage: coverage,
          warmup: warmup,
          tracker: tracker,
          hooks: hooks,
          trackerFilename: trackerFilename);
      exit(0);
    }
  } while (action == 'back');
}
