#! /usr/bin/env dcli

import 'dart:io';

import 'package:args/args.dart';
import 'package:critical_test/src/run.dart';

import 'package:dcli/dcli.dart' hide run;

/// running unit tests from vs-code doesn't seem to work as it spawns
/// two isolates and runs tests in parallel (even when using the -j1 option)
/// Given we are actively modifying the file system this is a bad idea.
/// So this script forces the test to run serially via the -j1 option.
///
void main(List<String> args) {
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
            'Re-runs only those tests that failed during the last run of critical_test.');

  final parsed = parser.parse(args);

  if (parsed['help'] as bool == true) {
    showUsage(parser);
  }

  var verbose = parsed['verbose'] as bool;
  Settings().setVerbose(enabled: verbose);

  var show = parsed['show'] as bool;

  var runFailed = parsed['runfailed'] as bool;

  if (runFailed && parsed.wasParsed('single')) {
    printerr(red('You may only pass one of --single or --runfailed'));
    showUsage(parser);
  }

  String? logPath;
  if (parsed.wasParsed('logTo')) {
    logPath = truepath(parsed['logTo'] as String);
  }

  final pathToProjectRoot = DartProject.fromPath(pwd).pathToProjectRoot;

  print('CT using project root: $pathToProjectRoot');

  if (parsed.wasParsed('single')) {
    var pathToScript = parsed['single'] as String;
    runSingleTest(
        testScript: pathToScript,
        pathToProjectRoot: pathToProjectRoot,
        logPath: logPath,
        show: show);
  } else if (runFailed) {
    runFailedTests(
        pathToProjectRoot: pathToProjectRoot, logPath: logPath, show: show);
  } else {
    runTests(
        pathToProjectRoot: pathToProjectRoot, logPath: logPath, show: show);
  }
}

/// Show useage.
void showUsage(ArgParser parser) {
  print(
      'Usage: critical_test [--show] [--logTo=<path to log>] [--single=<path to test>|--runfailed] [--no-hooks]');
  print(green('Runs unit tests only showing output from failed tests.'));
  print(parser.usage);
  exit(1);
}
