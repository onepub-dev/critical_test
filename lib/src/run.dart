#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

import 'process_output.dart';

late bool _show;
late String _logPath =
    join(Directory.systemTemp.path, 'critical_test', 'unit_tests.log');

late String hookPath =
    join(DartProject.current.pathToProjectRoot, 'tool', 'critical_test_hook');
late String prehookPath = join(hookPath, 'pre_test_hook');
late String posthookPath = join(hookPath, 'post_test_hook');

void runTests(
    {required String pathToProjectRoot, String? logPath, bool show = false}) {
  if (logPath != null) {
    _logPath = logPath;
  }
  _show = show;

  clearFailedTracker();

  print('Logging all output to $_logPath.');

  // ignore: missing_whitespace_between_adjacent_strings
  print('Legend: ${green('Successes')}:${orange('Failures')}'
      ':${red('Errors')}:${blue('Skipped')}');

  prepareLog();
  runPreHooks();

  _runAllTests(pathToProjectRoot);

  print('');

  runPostHooks();
}

/// Find an run each unit test file.
void _runAllTests(String pathToPackageRoot) {
  final pathToTestRoot = join(pathToPackageRoot, 'test');
  print('Running unit tests from $pathToTestRoot');

  find('*_test.dart', workingDirectory: pathToTestRoot).forEach((testScript) {
    runTest(
        testScript: testScript,
        pathToPackageRoot: pathToPackageRoot,
        show: _show,
        logPath: _logPath);
  });
}

void runSingleTest(
    {required String testScript,
    required String pathToProjectRoot,
    String? logPath,
    bool show = false}) {
  if (logPath != null) {
    _logPath = logPath;
  }
  _show = show;

  print('Logging all output to $_logPath.');

  // ignore: missing_whitespace_between_adjacent_strings
  print('Legend: ${green('Successes')}:${orange('Failures')}'
      ':${red('Errors')}:${blue('Skipped')}');

  prepareLog();
  runPreHooks();

  runTest(
      testScript: testScript,
      pathToPackageRoot: pathToProjectRoot,
      show: _show,
      logPath: _logPath);

  print('');

  runPostHooks();
}

void runFailedTests(
    {required String pathToProjectRoot, String? logPath, bool show = false}) {
  if (logPath != null) {
    _logPath = logPath;
  }
  _show = show;

  print('Logging all output to $_logPath.');

  // ignore: missing_whitespace_between_adjacent_strings
  print('Legend: ${green('Successes')}:${orange('Failures')}'
      ':${red('Errors')}:${blue('Skipped')}');

  final failedTests = read(pathToFailedTracker).toList();

  clearFailedTracker();

  prepareLog();
  runPreHooks();

  for (final failedTest in failedTests) {
    runTest(
        testScript: failedTest,
        pathToPackageRoot: pathToProjectRoot,
        show: _show,
        logPath: _logPath);
  }

  print('');

  runPostHooks();
}

void runPreHooks() => runHooks(prehookPath, 'pre-hook');
void runPostHooks() => runHooks(posthookPath, 'post-hook');

void runHooks(String pathTo, String type) {
  if (exists(prehookPath)) {
    var hooks = find('*', workingDirectory: pathTo, recursive: false).toList();
    hooks.sort((lhs, rhs) => lhs.compareTo(rhs));

    for (var file in hooks) {
      if (isFile(file)) {
        if (_isIgnoredFile(file)) return;
        if (isExecutable(file)) {
          print('Running $type $file');
          file.run;
        } else {
          Settings().verbose('Skipping non-executable $type $file');
        }
      } else {
        Settings().verbose('Ignoring non-file $type $file');
      }
    }
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
