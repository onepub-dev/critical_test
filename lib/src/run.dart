#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

import 'process_output.dart';
import 'run_hooks.dart';
import 'unit_tests/failed_tracker.dart';

import 'unit_tests/unit_test_selector.dart';
import 'util/counts.dart';

/// Runs all tests for the given dart package
/// found at [pathToProjectRoot].
/// returns true if all tests passed.
void runPackageTests({
  required ProcessOutput processor,
  required String pathToProjectRoot,
  required UnitTestSelector selector,
  required bool coverage,
  required bool warmup,
  required bool hooks,
  required String trackerFilename,
}) {
  if (warmup) {
    warmupAllPubspecs(pathToProjectRoot);
  }

  final tracker = FailedTracker.beginTestRun(trackerFilename);

  print(green(
      'Running unit tests for ${DartProject.fromPath(pwd).pubSpec.name}'));
  print('Logging all output to ${processor.logPath}');

  if (processor.showProgress) {
    // ignore: missing_whitespace_between_adjacent_strings
    print('Legend: ${green('Success')}:${red('Errors')}:${blue('Skipped')}');
  }

  processor.prepareLog();
  if (hooks) {
    runPreHooks(pathToProjectRoot);
  }

  _runAllTests(
      processor: processor,
      pathToPackageRoot: pathToProjectRoot,
      selector: selector,
      coverage: coverage,
      tracker: tracker);

  print('');

  if (hooks) {
    runPostHooks(pathToProjectRoot);
  }
  tracker.done();
}

/// Find and run each unit test file.
/// Returns true if all tests passed.
void _runAllTests(
    {required ProcessOutput processor,
    required String pathToPackageRoot,
    required UnitTestSelector selector,
    required bool coverage,
    required FailedTracker tracker}) {
  final pathToTestRoot = join(pathToPackageRoot, 'test');

  if (!exists(pathToTestRoot)) {
    print(orange('No tests found.'));
  } else {
    final testScripts =
        find('*_test.dart', workingDirectory: pathToTestRoot).toList();
    for (final testScript in testScripts) {
      _runTestScript(
          processor: processor,
          pathToPackageRoot: pathToPackageRoot,
          pathTo: testScript,
          testName: selector.testName,
          tags: selector.tags,
          excludeTags: selector.excludeTags,
          coverage: coverage,
          tracker: tracker);
    }
    processor.complete();
  }
}

/// returns true if the test passed.
void runSingleTest({
  required ProcessOutput processor,
  required String pathToProjectRoot,
  required String pathTo,
  required String? testName,
  required List<String> tags,
  required List<String> excludeTags,
  required bool coverage,
  required bool warmup,
  required FailedTracker tracker,
  required bool hooks,
  required String trackerFilename,
}) {
  print('Logging all output to ${processor.logPath}');

  if (warmup) {
    warmupAllPubspecs(pathToProjectRoot);
  }

  if (processor.showProgress) {
    // ignore: missing_whitespace_between_adjacent_strings
    print('Legend: ${green('Success')}:${red('Errors')}:${blue('Skipped')}');
  }
  processor.prepareLog();
  if (hooks) {
    runPreHooks(pathToProjectRoot);
  }

  _runTestScript(
      processor: processor,
      pathToPackageRoot: pathToProjectRoot,
      pathTo: pathTo,
      testName: testName,
      tags: tags,
      excludeTags: excludeTags,
      coverage: coverage,
      tracker: tracker);
  processor.complete();

  print('');

  if (hooks) {
    runPostHooks(pathToProjectRoot);
  }
}

/// returns true if all tests passed.
void runFailedTests({
  required ProcessOutput processor,
  required String pathToProjectRoot,
  required List<String> tags,
  required List<String> excludeTags,
  required bool coverage,
  required bool warmup,
  required bool hooks,
  required String trackerFilename,
  String? logPath,
}) {
  print('Logging all output to ${processor.logPath}');
  if (warmup) {
    warmupAllPubspecs(pathToProjectRoot);
  }

  if (processor.showProgress) {
    // ignore: missing_whitespace_between_adjacent_strings
    print('Legend: ${green('Success')}:${red('Errors')}:${blue('Skipped')}');
  }

  final tracker = FailedTracker.beginReplay(trackerFilename);
  final failedTests = tracker.failedTests;
  if (failedTests.isNotEmpty) {
    processor.prepareLog();
    if (hooks) {
      runPreHooks(pathToProjectRoot);
    }

    for (final failedTest in failedTests) {
      _runTestScript(
          processor: processor,
          pathTo: failedTest.pathTo,
          pathToPackageRoot: pathToProjectRoot,
          testName: failedTest.testName,
          coverage: coverage,
          tracker: tracker,
          tags: [],
          excludeTags: []);
    }
    processor.complete();

    print('');

    if (hooks) {
      runPostHooks(pathToProjectRoot);
    }
  } else {
    print(orange('No failed tests found'));
  }
  tracker.done();
}

/// Runs the tests contained in a single test script.
/// returns true if all tests passed.
void _runTestScript({
  required ProcessOutput processor,
  required String pathToPackageRoot,
  required String pathTo,
  required List<String> tags,
  required List<String> excludeTags,
  required bool coverage,
  required FailedTracker tracker,
  String? testName,
}) {
  try {
    final saved = Counts.copyFrom(processor.counts);
    DartSdk().run(
        args: [
          'test',
          ...[pathTo],
          '-j1',
          '-r',
          'json',
          if (coverage) '--coverage',
          if (coverage) join(pathToPackageRoot, 'coverage'),
          if (tags.isNotEmpty) ...['--tags=${tags.join(',')}'],
          if (excludeTags.isNotEmpty) ...[
            '--exclude-tags=${excludeTags.join(',')}'
          ],
          if (testName != null && testName.isNotEmpty) ...[
            '--plain-name=$testName'
          ],
          // testRoot
        ],
        workingDirectory: pathToPackageRoot,
        nothrow: true,
        progress: Progress((line) => processor.processOutput(line, tracker),
            stderr: (line) =>
                processor.tee(line, processor.processOutput, tracker)));

    // format_coverage --lcov --in=coverage --out=coverage.lcov
    // --packages=.packages --report-on=lib',

    /// dart run test returns 1 if any unit tests failed
    /// The problem is that also returns 1 if no unit tests were run
    /// so we do this check to see if any errors were generated.
    if (processor.counts.errors != saved.errors) {
      printerr(processor.errors.join('\n'));
    }
    // ignore: avoid_catches_without_on_clauses
  } catch (e, st) {
    printerr('Error ${e.toString()}, st: $st');
  }
}

/// Run pub get on all pubspec.yaml files we find in the project.
/// Unit tests won't run correctly if pub get hasn't been run.
void warmupAllPubspecs(String pathToProjectRoot) {
  /// warm up all test packages.
  for (final pubspec
      in find('pubspec.yaml', workingDirectory: pathToProjectRoot).toList()) {
    if (DartSdk().isPubGetRequired(dirname(pubspec))) {
      print(blue('Running pub get in ${dirname(pubspec)}'));
      DartSdk().runPubGet(dirname(pubspec));
    }
  }
}
