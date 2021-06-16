import 'package:critical_test/critical_test.dart' hide test;
import 'package:dcli/dcli.dart' hide equals;

import 'package:test/test.dart';

void main() {
  /// Check that the .failed_tracker file contains the correct information.
  test('failed tracker', () {
    withTempFile((logfile) {
      final progress = start(
          'critical_test --logPath=$logfile -v --track --single ${join('test_scripts', 'for_counts_test.dart')}',
          progress: Progress.capture(),
          nothrow: true,
          runInShell: true);

      final tracker = FailedTracker.beginReplay();
      var counts = lastCounts(progress.lines);
      expect(counts.errors, 2);
      expect(progress.exitCode!, equals(1));

      var failedTests = tracker.testsToRetry;
      expect(failedTests.length, equals(1));
      expect(
          failedTests[0], equals(join('test_scripts', 'for_counts_test.dart')));
      tracker.done();
    });
  });

  test('FailedTracker.beginTestRun - no failures', () {
    final tracker = FailedTracker.beginTestRun();

    expect(tracker.fileExists, isFalse);
    expect(tracker.backupExists, isFalse);
    expect(tracker.testsToRetry.length, isZero);

    tracker.done();

    expect(tracker.fileExists, isFalse);
    expect(tracker.backupExists, isFalse);
    expect(tracker.testsToRetry.length, isZero);
  });

  test('FailedTracker.beginTestRun - one failures', () {
    final tracker = FailedTracker.beginTestRun();
    tracker.recordFailure('test/me/failed_test.dart');

    expect(tracker.fileExists, isTrue);
    expect(tracker.backupExists, isFalse);
    expect(tracker.failedTests.length, equals(1));

    tracker.done();

    expect(tracker.fileExists, isTrue);
    expect(tracker.backupExists, isFalse);
    expect(tracker.failedTests.length, equals(1));
  });

  test('FailedTracker.beginTestRun - three failures', () {
    final tracker = FailedTracker.beginTestRun();
    tracker.recordFailure('test/me/failed_test.dart');
    tracker.recordFailure('test/me/failed_test2.dart');
    tracker.recordFailure('test/me/failed_test3.dart');

    expect(tracker.fileExists, isTrue);
    expect(tracker.backupExists, isFalse);
    expect(tracker.failedTests.length, equals(3));

    tracker.done();

    expect(tracker.fileExists, isTrue);
    expect(tracker.backupExists, isFalse);
    expect(tracker.failedTests.length, equals(3));
  });

  test('FailedTracker.beginTestRun - ignore duplicates', () {
    final tracker = FailedTracker.beginTestRun();
    tracker.recordFailure('test/me/failed_test.dart');
    tracker.recordFailure('test/me/failed_test2.dart');
    tracker.recordFailure('test/me/failed_test2.dart');

    expect(tracker.fileExists, isTrue);
    expect(tracker.backupExists, isFalse);
    expect(tracker.failedTests.length, equals(2));

    tracker.done();

    expect(tracker.fileExists, isTrue);
    expect(tracker.backupExists, isFalse);
    expect(tracker.failedTests.length, equals(2));
  });

  test('FailedTracker.beginReplay ', () {
    final tracker = FailedTracker.beginTestRun();
    tracker.recordFailure('test/me/failed_test.dart');
    tracker.recordFailure('test/me/failed_test2.dart');
    tracker.recordFailure('test/me/failed_test3.dart');
    tracker.done();

    /// now test the replay
    final replay = FailedTracker.beginReplay();

    expect(replay.fileExists, isFalse);
    expect(replay.backupExists, isTrue);
    expect(replay.testsToRetry.length, equals(3));

    replay.done();
    expect(replay.fileExists, isFalse);
    expect(replay.backupExists, isFalse);
  });

  test('FailedTracker restart replay ', () {
    final tracker = FailedTracker.beginTestRun();
    tracker.recordFailure('test/me/failed_test.dart');
    tracker.recordFailure('test/me/failed_test2.dart');
    tracker.recordFailure('test/me/failed_test3.dart');
    tracker.done();

    /// now test the replay
    var replay = FailedTracker.beginReplay();

    expect(replay.fileExists, isFalse);
    expect(replay.backupExists, isTrue);
    expect(replay.testsToRetry.length, equals(3));

    // restart replay without calling done to
    // ensure we restore failed tests from the
    // backup.
    replay = FailedTracker.beginReplay();

    expect(replay.fileExists, isFalse);
    expect(replay.backupExists, isTrue);
    expect(replay.testsToRetry.length, equals(3));
    replay.done();
    expect(replay.fileExists, isFalse);
    expect(replay.backupExists, isFalse);
  });

  test('FailedTracker.beginReplay with second round', () {
    final tracker = FailedTracker.beginTestRun();
    tracker.recordFailure('test/me/failed_test.dart');
    tracker.recordFailure('test/me/failed_test2.dart');
    tracker.recordFailure('test/me/failed_test3.dart');
    tracker.done();
    expect(tracker.failedTests.length, equals(3));

    /// now test the replay
    final replay = FailedTracker.beginReplay();

    expect(replay.fileExists, isFalse);
    expect(replay.backupExists, isTrue);
    expect(replay.testsToRetry.length, equals(3));

    replay.recordFailure('test/me/failed_test.dart');
    expect(replay.failedTests.length, equals(1));

    replay.done();

    /// test a second replay after the last test had a failure
    final part2 = FailedTracker.beginReplay();

    expect(part2.testsToRetry.length, equals(1));
    expect(part2.fileExists, isFalse);
    expect(part2.backupExists, isTrue);

    part2.done();
  });
}
