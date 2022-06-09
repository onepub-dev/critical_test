/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'dart:io';

import 'package:args/args.dart';
import 'package:critical_test/src/process_output.dart';
import 'package:critical_test/src/run.dart';
import 'package:critical_test/src/unit_tests/failed_tracker.dart';

import 'package:dcli/dcli.dart' hide run;

import 'arg_handler.dart';
import 'exceptions/critical_test_exception.dart';
import 'menu.dart';
import 'unit_tests/unit_test_selector.dart';

void run(List<String> args) {
  try {
    var processor = ProcessOutput();
    CriticalTest.run(args, processor);

    if (!processor.allPassed) {
      exit(1);
    }
    if (processor.nothingRan) {
      exit(5);
    }
  } on CriticalTestException catch (e) {
    printerr(e.message);
    exit(1);
  }

  exit(0);
}

class CriticalTest {
  static void run(List<String> args, ProcessOutput processor) {
    final parsedArgs = ParsedArgs.build()..parse(args);

    verbose(() => parsedArgs.toString());

    processor.showSuccess = parsedArgs.showAll;
    processor.showProgress = parsedArgs.showProgress;
    processor.logPath = parsedArgs.logPath;

    try {
      if (parsedArgs.menu) {
        testMenu(
            processor: processor,
            pathToProjectRoot: parsedArgs.pathToProjectRoot,
            coverage: parsedArgs.coverage,
            warmup: parsedArgs.warmup,
            track: true,
            hooks: parsedArgs.hooks,
            trackerFilename: parsedArgs.trackerFilename);
      } else if (parsedArgs.runFailed) {
        runFailedTests(
            processor: processor,
            pathToProjectRoot: parsedArgs.pathToProjectRoot,
            tags: parsedArgs.tags,
            excludeTags: parsedArgs.excludeTags,
            coverage: parsedArgs.coverage,
            warmup: parsedArgs.warmup,
            hooks: parsedArgs.hooks,
            trackerFilename: parsedArgs.trackerFilename);
      } else {
        /// Process each director or library passed.
        processDirAndLibraries(
            processor: processor,
            pathToProjectRoot: parsedArgs.pathToProjectRoot,
            selector: UnitTestSelector.fromArgs(parsedArgs),
            coverage: parsedArgs.coverage,
            warmup: parsedArgs.warmup,
            track: parsedArgs.track,
            hooks: parsedArgs.hooks,
            trackerFilename: parsedArgs.trackerFilename,
            parser: parsedArgs.parser);
      }

      if (processor.nothingRan) {
        print(orange('No tests ran!'));
      } else if (processor.allPassed) {
        print(green(
            'All tests passed. Success: ${processor.successCount}, Skipped: ${processor.skippedCount}'));
      } else {
        printerr(
            '${red('Some tests failed!')} Errors: ${red('${processor.erorrCount}')}, Success: ${green('${processor.successCount}')}, Skipped: ${blue('${processor.skippedCount}')}');
      }
    } on CriticalTestException catch (e) {
      printerr('A non recoverable error occured: ${e.message}');
    }
  }

  // static void runNamedTest(
  //     {required ProcessOutput processor,
  //     required String testName,
  //     required String pathToProjectRoot,
  //     String? tags,
  //     String? excludeTags,
  //     required bool coverage,
  //     required bool warmup,
  //     required bool track,
  //     required bool hooks,
  //     required String trackerFilename}) {
  //   FailedTracker tracker;
  //   if (track) {
  //     tracker = FailedTracker.beginTestRun(trackerFilename);
  //   } else {
  //     tracker = FailedTracker.ignoreFailures();
  //   }

  //   // run named test
  //   runSingleTest(
  //       processor: processor,
  //       pathToProjectRoot: pathToProjectRoot,

  //       selector: UnitTestSelector.fromTestName(testName: testName),
  //       excludeTags: excludeTags,
  //       coverage: coverage,
  //       warmup: warmup,
  //       tracker: tracker,
  //       hooks: hooks,
  //       trackerFilename: trackerFilename);

  //   tracker.done();
  // }

  static void processDirAndLibraries(
      {required ProcessOutput processor,
      required String pathToProjectRoot,
      required UnitTestSelector selector,
      required bool coverage,
      required bool warmup,
      required bool track,
      required bool hooks,
      required String trackerFilename,
      required ArgParser parser}) {
    FailedTracker tracker;
    if (track) {
      tracker = FailedTracker.beginTestRun(trackerFilename);
    } else {
      tracker = FailedTracker.ignoreFailures();
    }

    /// Process each director or library passed.
    for (final dirOrFile in selector.testPaths) {
      if (!exists(dirOrFile)) {
        printerr(red("The path ${truepath(dirOrFile)} doesn't exist."));
        showUsage(parser);
      }

      runSingleTest(
          processor: processor,
          pathTo: dirOrFile,
          testName: selector.testName,
          tags: selector.tags,
          excludeTags: selector.excludeTags,
          pathToProjectRoot: pathToProjectRoot,
          coverage: coverage,
          warmup: warmup,
          tracker: tracker,
          hooks: hooks,
          trackerFilename: trackerFilename);

      tracker.done();
    }
  }
}
