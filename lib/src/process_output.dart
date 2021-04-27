import 'dart:convert';

import 'package:dcli/dcli.dart';

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

void runTest(
    {required String testScript,
    required String pathToPackageRoot,
    required String logPath,
    bool show = false}) {
  _logPath = logPath;
  show = show;

  final pathToTestRoot = join(pathToPackageRoot, 'test');
  activeScript = relative(testScript, from: pathToTestRoot);

  /// print('running $testScript ');
  DartSdk().runPub(
      args: [
        'run',
        'test',
        '-j1',
        '-r',
        'json',
        testScript,
        '--coverage',
        join(pathToPackageRoot, 'coverage')
      ],
      workingDirectory: pathToPackageRoot,
      nothrow: true,
      progress: Progress(processOutput, stderr: processOutput));
}

void processOutput(String line) {
  var _line = line;
  if (!_line.startsWith('{"')) {
    final embeddedIndex = _line.indexOf('{"');
    if (embeddedIndex == -1) {
      /// Probably a raw output line from a unit test that spawns a sub process.
      lines.add(_line);
      return;
    }

    _line = _line.substring(embeddedIndex);
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

  if (map['skipped'] == 'true') {
    skipped++;
  }
  showProgress('$activeScript: Completed ${test.name}');
  lines.clear();
}

String group = '';
void processGroup(Map<String, dynamic> map) {
  group = _getNestedMap(map, 'group')['name'] as String;
}

void processSuite(Map<String, dynamic> map) {
  suite = _getNestedMap(map, 'suite')['path'] as String;
}

Map<String, dynamic> _getNestedMap(Map<String, dynamic> map, String name) =>
    map[name] as Map<String, dynamic>;

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
  print('');
  print(red('${'*' * 34} BEGIN ERROR (${failures + 1}) '.padRight(80, '*')));
  print(orange('Test: ${test.name}'));
  print(red('Error: $error'));

  print(orange('${'*' * 36} OUTPUT '.padRight(80, '*')));
  if (lines.isEmpty) {
    print('No output.');
  } else {
    lines.forEach(print);
  }
  print(orange('${'*' * 34} STACKTRACE '.padRight(80, '*')));
  print(stackTrace);
  print(blue('Rerun test via: critical_test --single=$pathToActiveScript'));
  print(red('${'*' * 32} END ERROR (${failures + 1}) '.padRight(80, '*')));
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
  final progress = '${green('$successes')}:${orange('$failures')}:'
      '${red('$errors')}:'
      '${blue('$skipped')} $message';

  // if (total != null) {
  //   final processed = successes + failures + skipped;
  //   progress = '${'Processed $processed/$total'} $progress';
  // }

  final term = Terminal();
  if (term.isAnsi) {
    term
      ..clearLine()
      ..startOfLine();
    echo(progress);
  } else {
    print(progress);
  }
  log(progress);
}

void log(String line) {
  _logPath.append(line);
}
