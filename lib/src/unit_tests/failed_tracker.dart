import 'dart:convert';

import 'package:critical_test/critical_test.dart';
import 'package:dcli/dcli.dart' as dcli;
import 'package:dcli/dcli.dart';

import 'unit_test.dart';

enum _RunType { full, replay, ignore }

class FailedTracker {
  static const defaultFilename = '.failed_tracker';
  final _failedTests = <UnitTest>[];

  final _RunType _runType;

  final String trackerFilename;

  FailedTracker.beginTestRun(this.trackerFilename) : _runType = _RunType.full {
    if (fileExists) dcli.delete(trackerFilename);
    if (dcli.exists(backupFilename)) dcli.delete(backupFilename);
  }

  FailedTracker.beginReplay(this.trackerFilename) : _runType = _RunType.replay {
    if (fileExists) {
      var failures = UnitTest.loadFailedTests(trackerFilename);

      _failedTests.addAll(failures);
      if (dcli.exists(backupFilename)) dcli.delete(backupFilename);
      dcli.copy(trackerFilename, backupFilename);
    } else {
      // check for backup
      if (backupExists) {
        var failures = UnitTest.loadFailedTests(backupFilename);
        _failedTests.addAll(failures);
      }
    }
  }

  /// We use this ctor when running test where we don't want to
  /// track the outcome and we don't want to clear out existing failed
  /// tests.
  FailedTracker.ignoreFailures()
      : trackerFilename = join(pathToCriticalTestConfig, defaultFilename),
        _runType = _RunType.ignore;

  /// Call [done] when the set of tests have completed.
  /// We can now delete the backup file as we should have
  /// a new and complete set of tests.
  void done() {
    if (_runType == _RunType.ignore) return;

    if (dcli.exists(backupFilename)) dcli.delete(backupFilename);
  }

  void recordError(UnitTest failedTest) {
    if (_runType == _RunType.ignore) return;

    if (_find(failedTest) == null) _failedTests.add(failedTest);

    _write();
  }

  void recordSuccess(UnitTest sucessfulTest) {
    if (_runType == _RunType.ignore) return;

    final found = _find(sucessfulTest);
    if (found != null) {
      _failedTests.remove(found);
    }
    _write();
  }

  UnitTest? _find(UnitTest find) {
    for (final unitTest in _failedTests) {
      if (unitTest.pathTo == find.pathTo &&
          ((unitTest.testName == find.testName))) {
        return unitTest;
      }
    }
  }

  void _write() {
    /// we have to re-write the entire file each time.
    /// this makes me unhappy.
    trackerFilename.write(jsonEncode(_failedTests));
  }

  void reset() {
    if (fileExists) dcli.delete(trackerFilename);
  }

  List<UnitTest> get failedTests => List.unmodifiable(_failedTests);

  String get backupFilename => '$trackerFilename.bak';

  bool get fileExists {
    return dcli.exists(trackerFilename);
  }

  bool get backupExists => dcli.exists(backupFilename);
}
