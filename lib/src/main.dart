import 'dart:io';

import 'package:args/args.dart';
import 'package:critical_test/src/process_output.dart';
import 'package:critical_test/src/run.dart';
import 'package:critical_test/src/unit_tests/failed_tracker.dart';

import 'package:dcli/dcli.dart' hide run;

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
    final parser = ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Shows this usage message.',
      )
      ..addOption('plain-name', abbr: 'N', help: 'Run a unit test by name.')
      ..addFlag('runfailed',
          abbr: 'f',
          negatable: false,
          help:
              'Re-runs only those tests that failed during the last run of critical_test.')
      ..addOption('tags',
          abbr: 't',
          help:
              'Select  unit tests to run via their tags. The syntax must confirm to the --tags option in the test package.')
      ..addOption('exclude-tags',
          abbr: 'x',
          help:
              'Select unit tests to exclude via their tags. The syntax must confirm to the --exclude-tags option in the test package.')
      ..addFlag(
        'show',
        negatable: false,
        abbr: 's',
        help: 'Also show output from successful unit tests.',
      )
      ..addFlag(
        'menu',
        negatable: false,
        abbr: 'm',
        help: 'Select from a menu of failed tests to view and re-run.',
      )
      ..addFlag(
        'progress',
        negatable: true,
        abbr: 'p',
        defaultsTo: true,
        help:
            'Show progress messages. Use --no-progress when running with a CI pipeline to minimize noise.',
      )
      ..addFlag(
        'coverage',
        negatable: false,
        defaultsTo: false,
        abbr: 'c',
        help: "Generates test coverage reports in the 'coverage' directory.",
      )
      ..addOption('logPath',
          abbr: 'g',
          help: 'Path to log all output. '
              'If set, all tests are logged to the given path.\n'
              'If not set, then all tests are logged to ${Directory.systemTemp.path}/critical_test/unit_test.log')
      ..addFlag(
        'hooks',
        abbr: 'o',
        negatable: true,
        defaultsTo: false,
        help: 'Supresses running of the pre and post hooks.',
      )
      ..addFlag(
        'warmup',
        abbr: 'w',
        defaultsTo: true,
        negatable: true,
        help: '''
Causes pub get to be run on all pubspec.yaml files found in the package.
Unit tests will fail if pub get hasn't been run.''',
      )
      ..addFlag(
        'track',
        abbr: 'k',
        hide: true,
        help: 'Used to force the recording of failures in .failed_tracker.',
      )
      ..addOption(
        'tracker',
        defaultsTo: FailedTracker.defaultFilename,
        hide: true,
        help:
            'Used to define an alternate filename for the fail test tracker. This is intended only for internal testing',
      )
      ..addFlag(
        'verbose',
        negatable: false,
        abbr: 'v',
        hide: true,
        help: 'Verbose logging for debugging of critical test.',
      );

    late final ArgResults parsed;
    try {
      parsed = parser.parse(args);
    } on FormatException catch (e) {
      printerr(red(e.message));
      printerr('');
      showUsage(parser);
    }

    if (parsed['help'] as bool == true) {
      showUsage(parser);
    }

    var verbose = parsed['verbose'] as bool;
    Settings().setVerbose(enabled: verbose);

    processor.showSuccess = parsed['show'] as bool;
    processor.showProgress = parsed['progress'] as bool;

    var menu = parsed['menu'] as bool;

    var coverage = parsed['coverage'] as bool;
    var warmup = parsed['warmup'] as bool;
    var track = parsed['track'] as bool;
    var hooks = parsed['hooks'] as bool;

    var runFailed = parsed['runfailed'] as bool;

    if (!atMostOne([menu, runFailed, parsed.wasParsed('plain-name')])) {
      printerr(red('You may only pass one of --plain-name or --runfailed'));
      showUsage(parser);
    }

    final trackerFilename = parsed['tracker'] as String;

    if (parsed.wasParsed('plain-name') &&
        (parsed.wasParsed('tags') || parsed.wasParsed('exclude-tags'))) {
      printerr(red(
          'You cannot combine "--plain-name" with "--tag" or "--exclude-tags"'));
      showUsage(parser);
    }

    if (parsed.wasParsed('logPath')) {
      final _logPath = truepath(parsed['logPath'] as String);
      if (exists(_logPath) && !isFile(_logPath)) {
        printerr(red('--logPath must specify a file'));
        showUsage(parser);
      }
      processor.logPath = _logPath;
    }

    String? tags;
    if (parsed.wasParsed('tags')) {
      tags = parsed['tags'] as String;
    }

    String? excludeTags;
    if (parsed.wasParsed('exclude-tags')) {
      excludeTags = parsed['exclude-tags'] as String;
    }

    final pathToProjectRoot = DartProject.fromPath(pwd).pathToProjectRoot;

    String? testName;

    if (parsed.wasParsed('plain-name')) {
      testName = parsed['plain-name'] as String;

      if (parsed.rest.isNotEmpty) {
        printerr(red(
            "You can't use --plain-name and a list of test directories/files together."));
        showUsage(parser);
        exit(1);
      }
    }

    try {
      if (menu) {
        testMenu(
            processor: processor,
            pathToProjectRoot: pathToProjectRoot,
            coverage: coverage,
            warmup: warmup,
            track: true,
            hooks: hooks,
            trackerFilename: trackerFilename);
      } else if (runFailed) {
        runFailedTests(
            processor: processor,
            pathToProjectRoot: pathToProjectRoot,
            tags: tags,
            excludeTags: excludeTags,
            coverage: coverage,
            warmup: warmup,
            hooks: hooks,
            trackerFilename: trackerFilename);
      } else {
        if (parsed.rest.isEmpty) {
          if (testName == null) {
            runPackageTests(
                processor: processor,
                pathToProjectRoot: pathToProjectRoot,
                tags: tags,
                excludeTags: excludeTags,
                coverage: coverage,
                warmup: warmup,
                hooks: hooks,
                trackerFilename: trackerFilename);
          } else {
            // run named test
            runNamedTest(
                processor: processor,
                testName: testName,
                pathToProjectRoot: pathToProjectRoot,
                tags: tags,
                excludeTags: excludeTags,
                coverage: coverage,
                warmup: warmup,
                track: track,
                hooks: hooks,
                trackerFilename: trackerFilename);
          }
        } else {
          /// Process each director or library passed.
          processDirAndLibraries(
              parsed: parsed,
              parser: parser,
              processor: processor,
              pathToProjectRoot: pathToProjectRoot,
              tags: tags,
              excludeTags: excludeTags,
              coverage: coverage,
              warmup: warmup,
              track: track,
              hooks: hooks,
              trackerFilename: trackerFilename);
        }
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

  static void runNamedTest(
      {required ProcessOutput processor,
      required String testName,
      required String pathToProjectRoot,
      String? tags,
      String? excludeTags,
      required bool coverage,
      required bool warmup,
      required bool track,
      required bool hooks,
      required String trackerFilename}) {
    FailedTracker tracker;
    if (track) {
      tracker = FailedTracker.beginTestRun(trackerFilename);
    } else {
      tracker = FailedTracker.ignoreFailures();
    }

    // run named test
    runSingleTest(
        processor: processor,
        selector: UnitTestSelector.fromTestName(testName: testName),
        pathToProjectRoot: pathToProjectRoot,
        tags: tags,
        excludeTags: excludeTags,
        coverage: coverage,
        warmup: warmup,
        tracker: tracker,
        hooks: hooks,
        trackerFilename: trackerFilename);

    tracker.done();
  }

  static void processDirAndLibraries(
      {required ArgResults parsed,
      required ArgParser parser,
      required ProcessOutput processor,
      required String pathToProjectRoot,
      String? tags,
      String? excludeTags,
      required bool coverage,
      required bool warmup,
      required bool track,
      required bool hooks,
      required String trackerFilename}) {
    FailedTracker tracker;
    if (track) {
      tracker = FailedTracker.beginTestRun(trackerFilename);
    } else {
      tracker = FailedTracker.ignoreFailures();
    }

    /// Process each director or library passed.
    for (final dirOrFile in parsed.rest) {
      if (!exists(dirOrFile)) {
        printerr(red("The path ${truepath(dirOrFile)} doesn't exist."));
        showUsage(parser);
      }

      runSingleTest(
          processor: processor,
          selector: UnitTestSelector.fromPath(pathTo: dirOrFile),
          pathToProjectRoot: pathToProjectRoot,
          tags: tags,
          excludeTags: excludeTags,
          coverage: coverage,
          warmup: warmup,
          tracker: tracker,
          hooks: hooks,
          trackerFilename: trackerFilename);

      tracker.done();
    }
  }

  /// Show useage.
  static void showUsage(ArgParser parser) {
    print(orange('Usage: critical_test [switches] [<directory | library>...]'));
    print(
        'Runs unit tests only showing output from failed tests and allows you to just re-run failed tests.');
    print(blue(
        "Run all tests in the project 'test' directory if no directories or libraries a passed"));
    print('critical_test');
    print('');
    print(blue('Re-run failed tests'));
    print('critical_tests --runfailed');
    print('');
    print(blue('Run all tests in a Dart Library or directory'));
    print('critical_tests [<directory or library to test>]...');
    print('');
    print(blue('Run a single test by name'));
    print('critical_tests --plain-name="[<group name> ]... <test name>"');
    print('');
    print('''
tags, exclude-tags and plain-name all act as filters when running against 
selected directories or libraries and restrict the set of tests that are run.''');
    print(parser.usage);
    exit(1);
  }

  /// no more than one of the passed bools may be true
  static bool atMostOne(List<bool> list) {
    var count = 0;

    for (final val in list) {
      if (val) count++;
    }
    return count <= 1;
  }
}
