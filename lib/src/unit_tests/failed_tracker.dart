import 'dart:convert';

import 'package:dcli/dcli.dart' as dcli;
import 'package:dcli/dcli.dart';

import 'unit_test.dart';

enum _RunType { full, replay, ignore }

class FailedTracker {
  static const defaultFilename = '.failed_tracker';
  final _failedTests = <UnitTest>[];

  final _retryTests = <UnitTest>[];
  final _RunType _runType;

  final String trackerFilename;

  FailedTracker.beginTestRun(this.trackerFilename) : _runType = _RunType.full {
    if (fileExists) dcli.delete(trackerFilename);
    if (dcli.exists(_backupFilename)) dcli.delete(_backupFilename);
  }

  FailedTracker.beginReplay(this.trackerFilename) : _runType = _RunType.replay {
    if (fileExists) {
      var failures = UnitTest.fromFile(trackerFilename);

      _retryTests.addAll(failures);
      if (dcli.exists(_backupFilename)) dcli.delete(_backupFilename);
      dcli.move(trackerFilename, _backupFilename);
    } else {
      // check for backup
      if (backupExists) {
        var failures = UnitTest.fromFile(_backupFilename);
        _retryTests.addAll(failures);
      }
    }
  }

  /// We use this ctor when running test where we don't want to
  /// track the outcome and we don't want to clear out existing failed
  /// tests.
  FailedTracker.ignoreFailures()
      : trackerFilename = defaultFilename,
        _runType = _RunType.ignore;

  /// Call [done] when the set of tests have completed.
  /// We can now delete the backup file as we should have
  /// a new and complete set of tests.
  void done() {
    if (_runType == _RunType.ignore) return;

    if (dcli.exists(_backupFilename)) dcli.delete(_backupFilename);
  }

  void recordFailure(UnitTest failedTest) {
    if (_runType == _RunType.ignore) return;

    _failedTests.add(failedTest);

    /// we have to re-write the entire file each time.
    /// this makes me unhappy.
    trackerFilename.write(jsonEncode(_failedTests));
  }

  void reset() {
    if (fileExists) dcli.delete(trackerFilename);
  }

  List<UnitTest> get testsToRetry => List.unmodifiable(_retryTests);

  List<UnitTest> get failedTests => List.unmodifiable(_failedTests);

  String get _backupFilename => '$trackerFilename.bak';

  bool get fileExists {
    return dcli.exists(trackerFilename);
  }

  bool get backupExists => dcli.exists(_backupFilename);
}
