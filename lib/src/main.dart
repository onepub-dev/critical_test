import 'dart:io';

import 'package:args/args.dart';
import 'package:critical_test/src/run.dart';

import 'package:dcli/dcli.dart' hide run;

import 'exceptions/critical_test_exception.dart';
import 'util/counts.dart';

class CriticalTest {
  static void run(List<String> args, Counts counts) {
    final parser = ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Shows this usage message.',
      )
      ..addOption('single',
          abbr: '1',
          help: 'Allows you to run a single unit tests by passing in its path.')
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
          abbr: 'l',
          help: 'Path to log all output. '
              'If set, all tests are logged to the given path.\n'
              'If not set, then all tests are logged to ${Directory.systemTemp.path}/critical_test/unit_test.log')
      ..addFlag(
        'no-hooks',
        abbr: 'n',
        negatable: false,
        help: 'Supresses running of the pre and post hooks.',
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

    var show = parsed['show'] as bool;
    var progress = parsed['progress'] as bool;

    var coverage = parsed['coverage'] as bool;

    var runFailed = parsed['runfailed'] as bool;

    if (runFailed && parsed.wasParsed('single')) {
      printerr(red('You may only pass one of --single or --runfailed'));
      showUsage(parser);
    }

    String? logPath;
    if (parsed.wasParsed('logPath')) {
      logPath = truepath(parsed['logPath'] as String);
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

    try {
      if (parsed.wasParsed('single')) {
        var pathToScript = parsed['single'] as String;
        runSingleTest(
            counts: counts,
            testScript: pathToScript,
            pathToProjectRoot: pathToProjectRoot,
            logPath: logPath,
            show: show,
            tags: tags,
            excludeTags: excludeTags,
            coverage: coverage,
            showProgress: progress);
      } else if (runFailed) {
        runFailedTests(
            counts: counts,
            pathToProjectRoot: pathToProjectRoot,
            logPath: logPath,
            show: show,
            tags: tags,
            excludeTags: excludeTags,
            coverage: coverage,
            showProgress: progress);
      } else {
        runTests(
            counts: counts,
            pathToProjectRoot: pathToProjectRoot,
            logPath: logPath,
            show: show,
            tags: tags,
            excludeTags: excludeTags,
            coverage: coverage,
            showProgress: progress);
      }

      if (counts.nothingRan) {
        print(orange('No tests ran!'));
      } else if (counts.allPassed) {
        print(green(
            'All tests passed. Success: ${counts.success}, Skipped: ${counts.skipped}'));
      } else {
        printerr(
            '${red('Some tests failed!')} Errors: ${red('${counts.errors}')}, Success: ${green('${counts.success}')}, Skipped: ${blue('${counts.skipped}')}');
      }
    } on CriticalTestException catch (e) {
      printerr('A non recoverable error occured: ${e.message}');
    }
  }

  /// Show useage.
  static void showUsage(ArgParser parser) {
    print(
        'Usage: critical_test  [--single=<path to test>|--runfailed] [--tags="tag,..."] [--exclude-tags="tag,..."] [--show] [--no-progress] [--converage] [--logPath=<path to log>] [--no-hooks] ');
    print(green('Runs unit tests only showing output from failed tests.'));
    print(parser.usage);
    exit(1);
  }
}
