#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

import 'failed_tracker.dart';
import 'process_output.dart';
import 'util/counts.dart';

late bool _show;
late String _logPath =
    join(Directory.systemTemp.path, 'critical_test', 'unit_tests.log');

late String hookPath =
    join(DartProject.fromPath(pwd).pathToProjectRoot, 'tool', 'critical_test');
late String prehookPath = join(hookPath, 'pre_hook');
late String posthookPath = join(hookPath, 'post_hook');

/// Runs all tests for the given dart package
/// found at [pathToProjectRoot].
/// returns true if all tests passed.
void runPackageTests(
    {required String pathToProjectRoot,
    String? logPath,
    bool show = false,
    required String? tags,
    required String? excludeTags,
    required bool coverage,
    required bool showProgress,
    required Counts counts,
    required bool warmup,
    required bool hooks}) {
  if (logPath != null) {
    _logPath = logPath;
  }
  _show = show;

  if (warmup) warmupAllPubspecs(pathToProjectRoot);

  final tracker = FailedTracker.beginTestRun();

  print(green(
      'Running unit tests for ${DartProject.fromPath(pwd).pubSpec.name}'));
  print('Logging all output to $_logPath');

  if (showProgress) {
    // ignore: missing_whitespace_between_adjacent_strings
    print('Legend: ${green('Success')}:${red('Errors')}:${blue('Skipped')}');
  }

  prepareLog();
  if (hooks) runPreHooks();

  _runAllTests(
      counts: counts,
      pathToPackageRoot: pathToProjectRoot,
      tags: tags,
      excludeTags: excludeTags,
      coverage: coverage,
      showProgress: showProgress,
      tracker: tracker);

  print('');

  if (hooks) runPostHooks();
  tracker.done();
}

/// Find and run each unit test file.
/// Returns true if all tests passed.
void _runAllTests(
    {required Counts counts,
    required String pathToPackageRoot,
    required String? tags,
    required String? excludeTags,
    required bool coverage,
    required bool showProgress,
    required FailedTracker tracker}) {
  final pathToTestRoot = join(pathToPackageRoot, 'test');

  if (!exists(pathToTestRoot)) {
    print(orange('No tests found.'));
  } else {
    var testScripts =
        find('*_test.dart', workingDirectory: pathToTestRoot).toList();
    for (var testScript in testScripts) {
      runTestScript(
          counts: counts,
          testScript: testScript,
          pathToPackageRoot: pathToPackageRoot,
          show: _show,
          logPath: _logPath,
          tags: tags,
          excludeTags: excludeTags,
          coverage: coverage,
          showProgress: showProgress,
          tracker: tracker);
    }
  }
}

/// returns true if the test passed.
void runSingleTest({
  required Counts counts,
  required String testScript,
  required String pathToProjectRoot,
  String? logPath,
  bool show = false,
  String? tags,
  String? excludeTags,
  required bool coverage,
  required bool showProgress,
  required bool warmup,
  required bool track,
  required bool hooks,
}) {
  if (logPath != null) {
    _logPath = logPath;
  }
  _show = show;

  print('Logging all output to $_logPath');

  if (warmup) warmupAllPubspecs(pathToProjectRoot);

  FailedTracker tracker;
  if (track) {
    tracker = FailedTracker.beginTestRun();
  } else {
    tracker = FailedTracker.ignoreFailures();
  }

  if (showProgress) {
    // ignore: missing_whitespace_between_adjacent_strings
    print('Legend: ${green('Success')}:${red('Errors')}:${blue('Skipped')}');
  }
  prepareLog();
  if (hooks) runPreHooks();

  runTestScript(
      counts: counts,
      testScript: testScript,
      pathToPackageRoot: pathToProjectRoot,
      show: _show,
      logPath: _logPath,
      tags: tags,
      excludeTags: excludeTags,
      coverage: coverage,
      showProgress: showProgress,
      tracker: tracker);

  print('');

  if (hooks) runPostHooks();
  tracker.done();
}

/// returns true if all tests passed.
void runFailedTests({
  required Counts counts,
  required String pathToProjectRoot,
  String? logPath,
  bool show = false,
  String? tags,
  String? excludeTags,
  required bool coverage,
  required bool showProgress,
  required bool warmup,
  required bool hooks,
}) {
  if (logPath != null) {
    _logPath = logPath;
  }
  _show = show;

  print('Logging all output to $_logPath');
  if (warmup) warmupAllPubspecs(pathToProjectRoot);

  if (showProgress) {
    // ignore: missing_whitespace_between_adjacent_strings
    print('Legend: ${green('Success')}:${red('Errors')}:${blue('Skipped')}');
  }

  final tracker = FailedTracker.beginReplay();
  final failedTests = tracker.testsToRetry;
  if (failedTests.isEmpty) {
    prepareLog();
    if (hooks) runPreHooks();

    for (final failedTest in failedTests) {
      runTestScript(
          counts: counts,
          testScript: failedTest,
          pathToPackageRoot: pathToProjectRoot,
          show: _show,
          logPath: _logPath,
          tags: tags,
          excludeTags: excludeTags,
          coverage: coverage,
          showProgress: showProgress,
          tracker: tracker);
    }

    print('');

    if (hooks) runPostHooks();
  } else {
    print(orange('No failed tests found'));
  }
  tracker.done();
}

void runPreHooks() => runHooks(prehookPath, 'pre_hook');
void runPostHooks() => runHooks(posthookPath, 'post_hook');

void runHooks(String pathTo, String type) {
  if (exists(prehookPath)) {
    var hooks = find('*', workingDirectory: pathTo, recursive: false).toList();
    hooks.sort((lhs, rhs) => lhs.compareTo(rhs));
    if (hooks.isEmpty) {
      print(orange('No $type found in $prehookPath.'));
    }

    for (var file in hooks) {
      if (isFile(file)) {
        if (_isIgnoredFile(file)) return;
        if (isExecutable(file)) {
          print('Running $type $file');
          if (Platform.isWindows || which('dcli').notfound) {
            /// No shebang support on windows or dcli not globally activated so we must run with the dart exe.
            DartSdk().run(args: [file], terminal: true);
          } else {
            file.run;
          }
        } else {
          print(orange('Skipping non-executable $type $file'));
        }
      } else {
        Settings().verbose('Ignoring non-file $type $file');
      }
    }
  } else {
    print(
        blue("The critical_test $type directory $prehookPath doesn't exist."));
  }
}

const _ignoredExtensions = ['.yaml', '.ini', '.config'];
bool _isIgnoredFile(String pathToHook) {
  final _extension = extension(pathToHook);

  return _ignoredExtensions.contains(_extension);
}

void prepareLog() {
  if (!exists(dirname(_logPath))) {
    createDir(dirname(_logPath), recursive: true);
  }
  _logPath.truncate();
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
