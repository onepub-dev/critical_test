/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';

import 'process_output.dart';
import 'run.dart';
import 'unit_tests/failed_tracker.dart';
import 'unit_tests/unit_test.dart';

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

  const action = 'back';
  do {
    print(green('Select the test to view'));
    final selected = menu<UnitTest>(
        prompt: 'Select Test:',
        options: [...failedTests, const UnitTest.exitOption()],
        defaultOption: failedTests.first,
        format: (unitTest) => unitTest.testName);

    if (selected == const UnitTest.exitOption()) {
      exit(0);
    }
    print(selected);
    final action = menu(
        prompt: 'Action: ', options: ['run', 'back'], defaultOption: 'run');

    if (action == 'run') {
      print('Running: $selected');
      runSingleTest(
          processor: processor,
          pathToProjectRoot: pathToProjectRoot,
          pathTo: selected.pathTo,
          testName: selected.testName,
          tags: [],
          excludeTags: [],
          coverage: coverage,
          warmup: warmup,
          tracker: tracker,
          hooks: hooks,
          trackerFilename: trackerFilename);
      exit(0);
    }
  } while (action == 'back');
}
