import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';

import 'json/test.dart';
import 'unit_tests/failed_tracker.dart';
import 'unit_tests/unit_test.dart';
import 'util/counts.dart';

class ProcessOutput {
  String suite = '';

  // late String activeScript;
  Test test = Test.empty();

  /// Total tests to be processed.
  int? total;

  late String logPath =
      join(Directory.systemTemp.path, 'critical_test', 'unit_tests.log');

  /// If true we show progress and failed tests
  bool showProgress = true;

  /// If true we show successful tests.
  bool showSuccess = false;

  /// gets replaced when runTest is called.
  /// We just init it here so its nnbd.
  final Counts _counts = Counts();

  final _errors = <String>[];

  bool get allPassed => _counts.allPassed;

  bool get nothingRan => _counts.nothingRan;

  Counts get counts => _counts;

  List<String> get errors => _errors;

  int get skippedCount => counts.skipped;
  int get successCount => counts.success;
  int get erorrCount => counts.errors;

  void tee(
      String line,
      void Function(String line, FailedTracker tracker) processOutput,
      FailedTracker tracker) {
    _errors.add(line);
    processOutput(line, tracker);
  }

  void processOutput(String line, FailedTracker tracker) {
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

    final unitTest = UnitTest(pathTo: test.path, testName: test.name);

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
        processTestDone(map, tracker, unitTest);
        break;

      case 'print':
        processPrint(map);
        break;

      case 'error':
        processError(map, tracker, group, unitTest);
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
        printerr(red('Unexpected line $line'));
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
    // final success = map['success'] as bool;
    // if (success) {
    //   printProgress('${test.path}: Tests completed.');
    // } else {
    //   printProgress('${test.path}: Tests completed with some failures');
    // }
  }

  void processError(Map<String, dynamic> map, FailedTracker tracker,
      String group, UnitTest unitTest) {
    final stackTrace = map['stackTrace'] as String;
    final error = map['error'] as String;
    printFailedTest(error, stackTrace, tracker, group, unitTest);
  }

  void processPrint(Map<String, dynamic> map) {
    final line = map['message'] as String;
    lines.add(line);
    if (showSuccess) {
      print(line);
    }
    log(line);
  }

  void processTestStart(Map<String, dynamic> map) {
    test = Test.fromJson(_getNestedMap(map, 'test'));
    if (test.name == 'Loading.') {
      printProgress(test.name);
    } else {
      printProgress('Running: ${test.path} : ${test.name}');
    }
  }

  void processTestDone(
      Map<String, dynamic> map, FailedTracker tracker, UnitTest unitTest) {
    final result = map['result'] as String;

    if (map['hidden'] == true) {
      return;
    }
    // skipped is when the 'skipped' parameter is used
    // hidden is when tags/exclude-tags is used.
    // we treat them the same.
    if (map['skipped'] == true) {
      _counts.incSkipped();

      /// even though it didn't run the result tag should be success
      assert(result == 'success');
    } else {
      switch (result) {
        case 'success':
          _counts.success++;
          tracker.recordSuccess(unitTest);
          break;

        /// if the test had a TestFailure but no other errors.
        case 'failure':
          _counts.errors++;
          tracker.recordError(unitTest);
          break;

        /// if the test had an error other than a TestFailure.
        case 'error':
          _counts.errors++;
          tracker.recordError(unitTest);
          break;
      }
    }

    // printProgress('${test.path}: Completed: ${test.name}');
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
        printerr('unexpected type: $type');
        break;
    }
  }

  void printFailedTest(String error, String stackTrace, FailedTracker tracker,
      String group, UnitTest unitTest) {
    printerr('');
    printerr(red(
        '${'*' * 34} BEGIN ERROR (${_counts.errors + 1}) '.padRight(80, '*')));
    printerr(orange('Test: $unitTest'));
    printerr(red('Error: $error'));

    printerr(orange('${'*' * 36} OUTPUT '.padRight(80, '*')));
    if (lines.isEmpty) {
      printerr('No output.');
    } else {
      lines.forEach(print);
    }
    printerr(orange('${'*' * 34} STACKTRACE '.padRight(80, '*')));
    printerr(stackTrace);
    final nameSwitch = '--plain-name="${unitTest.testName}"';
    printerr(blue('Rerun test via: critical_test $nameSwitch'));
    printerr(red(
        '${'*' * 32} END ERROR (${_counts.errors + 1}) '.padRight(80, '*')));
  }

  List<String> lines = <String>[];

  String _lastProgressLine = '';

  void printProgress(String message) {
    final columns = Terminal().columns;

    /// print(columns);
    ///
    var logline = '${green('${_counts.success}')}:'
        '${red('${_counts.errors}')}:'
        '${blue('${_counts.skipped}')} $message';

    /// We allow 24 chars for the counts.
    if (message.length > columns - 24) {
      /// print('progess: ${message.length}');
      message = Format().limitString(message, width: columns - 24);
    }

    var progress = '${green('${_counts.success}')}:'
        '${red('${_counts.errors}')}:'
        '${blue('${_counts.skipped}')} $message';

    // if (total != null) {
    //   final processed = success + failures + skipped;
    //   progress = '${'Processed $processed/$total'} $progress';
    // }

    if (showProgress) {
      final term = Terminal();
      term.showCursor(show: false);
      term.overwriteLine(progress.trim().padRight(_lastProgressLine.length));
      term.showCursor(show: true);
      _lastProgressLine = progress;
    }
    log(logline);
  }

  void log(String line) {
    logPath.append(Ansi.strip(line));
  }

  void prepareLog() {
    if (!exists(dirname(logPath))) {
      createDir(dirname(logPath), recursive: true);
    }
    logPath.truncate();
  }

  void complete() {
    printProgress('Finished');
  }
}
