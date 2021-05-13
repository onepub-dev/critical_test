import 'dart:io';

import 'package:args/args.dart';
import 'package:critical_test/src/run.dart';

import 'package:dcli/dcli.dart' hide run;

class CriticalTest {
  static bool run(List<String> args) {
    final parser = ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Shows this usage message.',
      )
      ..addFlag(
        'no-hooks',
        abbr: 'n',
        negatable: false,
        help: 'Supresses running of the pre and post hooks.',
      )
      ..addFlag(
        'show',
        negatable: false,
        abbr: 's',
        help: 'Also show output from successful unit tests.',
      )
      ..addFlag(
        'verbose',
        negatable: false,
        abbr: 'v',
        hide: true,
        help: 'Verbose logging for debugging of critical test.',
      )
      ..addFlag(
        'coverage',
        negatable: false,
        defaultsTo: false,
        abbr: 'c',
        help: "Generates test coverage reports in the 'coverage' directory.",
      )
      ..addOption('logTo',
          abbr: 'l',
          help: 'Path to log all output. '
              'If set, all tests are logged to the given path.\n'
              'If not set, then all tests are logged to ${Directory.systemTemp}/dcli/unit_test.log')
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
              'Select unit tests to exclude via their tags. The syntax must confirm to the --exclude-tags option in the test package.');

    final parsed = parser.parse(args);

    if (parsed['help'] as bool == true) {
      showUsage(parser);
    }

    var verbose = parsed['verbose'] as bool;
    Settings().setVerbose(enabled: verbose);

    var show = parsed['show'] as bool;

    var coverage = parsed['coverage'] as bool;

    var runFailed = parsed['runfailed'] as bool;

    if (runFailed && parsed.wasParsed('single')) {
      printerr(red('You may only pass one of --single or --runfailed'));
      showUsage(parser);
    }

    String? logPath;
    if (parsed.wasParsed('logTo')) {
      logPath = truepath(parsed['logTo'] as String);
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

    var passed = false;
    if (parsed.wasParsed('single')) {
      var pathToScript = parsed['single'] as String;
      passed = runSingleTest(
          testScript: pathToScript,
          pathToProjectRoot: pathToProjectRoot,
          logPath: logPath,
          show: show,
          tags: tags,
          excludeTags: excludeTags,
          coverage: coverage);
    } else if (runFailed) {
      passed = runFailedTests(
          pathToProjectRoot: pathToProjectRoot,
          logPath: logPath,
          show: show,
          tags: tags,
          excludeTags: excludeTags,
          coverage: coverage);
    } else {
      passed = runTests(
          pathToProjectRoot: pathToProjectRoot,
          logPath: logPath,
          show: show,
          tags: tags,
          excludeTags: excludeTags,
          coverage: coverage);
    }

    return passed;
  }

  /// Show useage.
  static void showUsage(ArgParser parser) {
    print(
        'Usage: critical_test [--show] [--logTo=<path to log>] [--single=<path to test>|--runfailed] [--no-hooks]');
    print(green('Runs unit tests only showing output from failed tests.'));
    print(parser.usage);
    exit(1);
  }
}
