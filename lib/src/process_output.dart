import 'dart:convert';

import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';

import 'exceptions/critical_test_exception.dart';
import 'json/test.dart';

String suite = '';

late String activeScript;
Test test = Test.empty();
int successes = 0;
int failures = 0;
int errors = 0;
int skipped = 0;
bool show = false;

/// Total tests to be processed.
int? total;

late String _logPath;

/// returns true if all tests passed.
bool runTest({
  required String testScript,
  required String pathToPackageRoot,
  required String logPath,
  required String? tags,
  required String? excludeTags,
  bool show = false,
  required bool coverage,
}) {
  _logPath = logPath;
  show = show;

  var passed = true;

  activeScript = relative(testScript, from: pathToPackageRoot);

  if (!exists(activeScript)) {
    throw CriticalTestException(
        'The test script ${truepath(activeScript)} does not exist.');
  }

  try {
    final progress = DartSdk().run(
        args: [
          'run',
          'test',
          '-j1',
          '-r',
          'json',
          if (coverage) '--coverage',
          if (coverage) '${join(pathToPackageRoot, 'coverage')}',
          if (tags != null) ...['--tags', '"$tags"'],
          if (excludeTags != null) ...['--exclude-tags', '"$excludeTags"'],
          testScript,
        ],
        workingDirectory: pathToPackageRoot,
        nothrow: true,
        progress: Progress(processOutput,
            stderr: (line) => tee(line, processOutput)));

    // format_coverage --lcov --in=coverage --out=coverage.lcov --packages=.packages --report-on=lib',
    passed &= progress.exitCode == 0;
    if (!passed) {
      print(_errors.join('\n'));
    }
  } catch (e, st) {
    print('Error ${e.toString()}, st: $st');
    passed = false;
  }

  return passed;
}

final _errors = <String>[];
void tee(String line, void Function(String line) processOutput) {
  _errors.add(line);
  processOutput(line);
}

@visibleForTesting
set logToPath(String logToPath) => _logPath = logToPath;

void processOutput(String line) {
  var _line = line.trim();
  if (!_line.startsWith('{"')) {
    final embeddedIndex = _line.indexOf('{"');
    if (embeddedIndex == -1) {
      /// Probably a raw output line from a unit test that spawns a sub process.
      lines.add(_line);
      return;
    }

    _line = _line.substring(embeddedIndex);
  }

  /// check for and trim raw output from a spawned subprocess
  var lastBrace = _line.lastIndexOf('}');
  if (lastBrace + 1 != _line.length) {
    var tail = _line.substring(lastBrace + 1);
    lines.add(tail);
    _line = _line.substring(0, lastBrace + 1);
  }

  final map = jsonDecode(_line) as Map<String, dynamic>;

  final type = map['type'] as String;

  switch (type) {
    case 'suite':
      processSuite(map);
      break;

    case 'group':
      processGroup(map);
      break;

    case 'testStart':
      processTestStart(map);
      break;

    case 'testDone':
      processTestDone(map);
      break;

    case 'print':
      processPrint(map);
      break;

    case 'error':
      processError(map);
      break;

    /// all tests are complete
    case 'done':
      processDone(map);
      break;

    case 'allSuites':
      processAllSuites(map);
      break;

    case 'start':
    case 'debug':
      // ignored
      break;
    default:
      print(red('Unexpected line $line'));
  }

  // if (map.containsKey('testID')) {
  //   processTestID(map);
  // } else if (map.containsKey('test')) {
  //   processTest(map);
  // }

  // print('\n$line');
}

void processAllSuites(Map<String, dynamic> map) {
  /// Get the total no. of tests to run.
  total = map['count'] as int;
}

/// All tests have completed.
void processDone(Map<String, dynamic> map) {
  final success = map['success'] as bool;
  if (success) {
    showProgress('$activeScript: Tests completed.');
  } else {
    showProgress('$activeScript: Tests completed with some failures');
  }
}

void processError(Map<String, dynamic> map) {
  final stackTrace = map['stackTrace'] as String;
  final error = map['error'] as String;
  printFailedTest(error, stackTrace);
}

void processPrint(Map<String, dynamic> map) {
  final line = map['message'] as String;
  lines.add(line);
  if (show) {
    print(line);
  }
  log(line);
}

void processTestStart(Map<String, dynamic> map) {
  test = Test.fromJson(_getNestedMap(map, 'test'));

  showProgress('$activeScript: ${test.name}');
}

void processTestDone(Map<String, dynamic> map) {
  final result = map['result'] as String;

  if (map['hidden'] == true) {
    return;
  }
  // skipped is when the 'skipped' parameter is used
  // hidden is when tags/exclude-tags is used.
  // we treat them the same.
  if (map['skipped'] == true) {
    skipped++;
    print('skipping: ${test.name}');

    /// even though it didn't run the result tag should be success
    assert(result == 'success');
  } else {
    switch (result) {
      case 'success':
        successes++;
        break;

      /// if the test had a TestFailure but no other errors.
      case 'failure':
        failures++;
        break;

      /// if the test had an error other than a TestFailure.
      case 'error':
        errors++;
        break;
    }
  }

  showProgress('$activeScript: Completed ${test.name}');
  lines.clear();
}

String group = '';
void processGroup(Map<String, dynamic> map) {
  group = (_getNestedMap(map, 'group')['name'] ?? '') as String;
}

void processSuite(Map<String, dynamic> map) {
  suite = _getNestedMap(map, 'suite')['path'] as String;
}

Map<String, dynamic> _getNestedMap(Map<String, dynamic> map, String key) =>
    map[key] as Map<String, dynamic>;

void processTestID(Map<String, dynamic> map) {
  final type = map['type'] as String;
  // print('map type: $type');
  switch (type) {
    default:
      print('unexpected type: $type');
      break;
  }
}

void printFailedTest(String error, String stackTrace) {
  var pathToActiveScript = join('test', activeScript);
  trackFailedTest(pathToActiveScript);
  printerr('');
  printerr(red(
      '${'*' * 34} BEGIN ERROR (${errors + failures + 1}) '.padRight(80, '*')));
  printerr(orange('Test: ${test.name}'));
  printerr(red('Error: $error'));

  printerr(orange('${'*' * 36} OUTPUT '.padRight(80, '*')));
  if (lines.isEmpty) {
    printerr('No output.');
  } else {
    lines.forEach(print);
  }
  printerr(orange('${'*' * 34} STACKTRACE '.padRight(80, '*')));
  printerr(stackTrace);
  printerr(blue('Rerun test via: critical_test --single=$pathToActiveScript'));
  printerr(red(
      '${'*' * 32} END ERROR (${errors + failures + 1}) '.padRight(80, '*')));
}

final pathToFailedTracker = '.failed_tracker';
final failedTests = <String>{};

void trackFailedTest(String activeScript) {
  if (failedTests.contains(activeScript)) return;

  failedTests.add(activeScript);
  pathToFailedTracker.append(activeScript);
}

void clearFailedTracker() {
  pathToFailedTracker.truncate();
}

List<String> lines = <String>[];

void showProgress(String message) {
  final columns = Terminal().columns;

  /// print(columns);

  /// We allow 20 chars for the counts.
  if (message.length > columns - 24) {
    /// print('progess: ${message.length}');
    message = message.substring(0, columns - 24) + '...';
  }

  var progress = '${green('$successes')}:${orange('$failures')}:'
      '${red('$errors')}:'
      '${blue('$skipped')} $message';

  // if (total != null) {
  //   final processed = successes + failures + skipped;
  //   progress = '${'Processed $processed/$total'} $progress';
  // }

  final term = Terminal();
  term.overwriteLine(progress);
  log(progress);
}

void log(String line) {
  _logPath.append(Ansi.strip(line));
}
