import 'package:dcli/dcli.dart' as dcli;

enum _RunType { full, replay, ignore }

class FailedTracker {
  final _failedTrackerFilename = '.failed_tracker';
  final _failedTests = <String>{};

  final _retryTests = <String>{};
  final _RunType _runType;

  FailedTracker.beginTestRun() : _runType = _RunType.full {
    if (fileExists) dcli.delete(_failedTrackerFilename);
    if (dcli.exists(_backupFilename)) dcli.delete(_backupFilename);
  }

  FailedTracker.beginReplay() : _runType = _RunType.replay {
    if (fileExists) {
      _retryTests.addAll(dcli.read(_failedTrackerFilename).toList());
      if (dcli.exists(_backupFilename)) dcli.delete(_backupFilename);
      dcli.move(_failedTrackerFilename, _backupFilename);
    } else {
      // check for backup
      if (backupExists) {
        _retryTests.addAll(dcli.read(_backupFilename).toList());
      }
    }
  }

  /// We use this ctor when running test where we don't want to
  /// track the outcome and we don't want to clear out existing failed
  /// tests.
  FailedTracker.ignoreFailures() : _runType = _RunType.ignore;

  /// Call [done] when the set of tests have completed.
  /// We can now delete the backup file as we should have
  /// a new and complete set of tests.
  void done() {
    if (_runType == _RunType.ignore) return;

    if (dcli.exists(_backupFilename)) dcli.delete(_backupFilename);
  }

  void recordFailure(String activeScript) {
    if (_runType == _RunType.ignore) return;
    if (_failedTests.contains(activeScript)) return;

    _failedTests.add(activeScript);
    _failedTrackerFilename.append(activeScript);
  }

  void reset() {
    if (fileExists) dcli.delete(_failedTrackerFilename);
  }

  List<String> get testsToRetry => _retryTests.toList();

  /// During a run each time a test fails it is added
  /// to the list of [failedTests].
  List<String> get failedTests => _failedTests.toList();

  String get _backupFilename => '$_failedTrackerFilename.bak';

  bool get fileExists {
    return dcli.exists(_failedTrackerFilename);
  }

  bool get backupExists => dcli.exists(_backupFilename);
}
