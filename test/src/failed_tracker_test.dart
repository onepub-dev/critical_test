@Timeout(Duration(minutes: 5))
import 'package:critical_test/critical_test.dart';
import 'package:critical_test/src/unit_tests/failed_tracker.dart';
import 'package:critical_test/src/unit_tests/unit_test.dart';
import 'package:dcli/dcli.dart' hide equals, run;

import 'package:test/test.dart';

void main() {
  /// Check that the .failed_tracker file contains the correct information.
  test('failed tracker', () {
    withTempFile((logfile) {
      // var script = Script.capture((_) async {
      //   run([
      //     '--logPath=$logfile',
      //     '-v',
      //     '--track',
      //     '${join('test_scripts', 'for_counts_test.dart')}'
      //   ]);
      // });
      // final combined = script.combineOutput();
      // final output = waitForEx(combined.text);
      // var exitCode = waitForEx(script.exitCode);
      withTempFile((trackerFilename) {
        final progress = start(
            'bin/critical_test.dart --tracker=$trackerFilename --logPath=$logfile -v --track ${join('test_scripts', 'for_counts_test.dart')}',
            progress: Progress.capture(),
            nothrow: true,
            runInShell: true);

        final tracker = FailedTracker.beginReplay(trackerFilename);
        var counts = lastCounts(progress.lines);
        expect(counts.errors, 2);
        expect(progress.exitCode!, equals(1));

        var failedTests = tracker.testsToRetry;
        expect(failedTests.length, equals(2));
        expect(failedTests[0].testName, equals("Group ##1 Intentional fail"));

        expect(failedTests[1].pathTo,
            equals(truepath('test_scripts', 'for_counts_test.dart')));
        expect(
            failedTests[1].testName, equals("Group ##1 2nd Intentional fail"));

        tracker.done();
      });
    });
  });

  // test('failed tracker 2', () {
  //   withTempFile((logfile) {
  //     run([
  //       '--logPath=$logfile',
  //       '-v',
  //       '--track',
  //       '${join('test_scripts', 'for_counts_test.dart')}'
  //     ]);
  //   });
  // });

  test('run test by name', () {
    withTempFile((logfile) {
      withTempFile((trackerFilename) {
        final progress = start(
          'bin/critical_test.dart --tracker=$trackerFilename  --logPath=$logfile -v --track --plain-name "Group ##1 Intentional fail" test_scripts',
          progress: Progress.capture(),
          nothrow: true,
          runInShell: true,
        );

        final tracker = FailedTracker.beginReplay(trackerFilename);
        var counts = lastCounts(progress.lines);
        expect(counts.errors, 1);
        expect(progress.exitCode!, equals(1));

        var failedTests = tracker.testsToRetry;
        expect(failedTests.length, equals(1));
        expect(failedTests[0].pathTo,
            equals(truepath('test_scripts', 'for_counts_test.dart')));

        expect(failedTests[0].testName, equals("Group ##1 Intentional fail"));

        tracker.done();
      });
    });
  });

  test('FailedTracker.beginTestRun - no failures', () {
    withTempFile((trackerFilename) {
      final tracker = FailedTracker.beginTestRun(trackerFilename);

      expect(tracker.fileExists, isFalse);
      expect(tracker.backupExists, isFalse);
      expect(tracker.testsToRetry.length, isZero);

      tracker.done();

      expect(tracker.fileExists, isFalse);
      expect(tracker.backupExists, isFalse);
      expect(tracker.testsToRetry.length, isZero);
    });
  });

  test('FailedTracker.beginTestRun - one failures', () {
    withTempFile((trackerFilename) {
      final tracker = FailedTracker.beginTestRun(trackerFilename);
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test.dart'));

      expect(tracker.fileExists, isTrue);
      expect(tracker.backupExists, isFalse);
      expect(tracker.failedTests.length, equals(1));

      tracker.done();

      expect(tracker.fileExists, isTrue);
      expect(tracker.backupExists, isFalse);
      expect(tracker.failedTests.length, equals(1));
    });
  });

  test('FailedTracker.beginTestRun - three failures', () {
    withTempFile((trackerFilename) {
      final tracker = FailedTracker.beginTestRun(trackerFilename);
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test.dart'));
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test2.dart'));
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test3.dart'));

      expect(tracker.fileExists, isTrue);
      expect(tracker.backupExists, isFalse);
      expect(tracker.failedTests.length, equals(3));

      tracker.done();

      expect(tracker.fileExists, isTrue);
      expect(tracker.backupExists, isFalse);
      expect(tracker.failedTests.length, equals(3));
    });
  });

  test('FailedTracker.beginReplay ', () {
    withTempFile((trackerFilename) {
      final tracker = FailedTracker.beginTestRun(trackerFilename);
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test.dart'));
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test2.dart'));
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test3.dart'));
      tracker.done();

      /// now test the replay
      final replay = FailedTracker.beginReplay(trackerFilename);

      expect(replay.fileExists, isFalse);
      expect(replay.backupExists, isTrue);
      expect(replay.testsToRetry.length, equals(3));

      replay.done();
      expect(replay.fileExists, isFalse);
      expect(replay.backupExists, isFalse);
    });
  });

  test('FailedTracker restart replay ', () {
    withTempFile((trackerFilename) {
      final tracker = FailedTracker.beginTestRun(trackerFilename);
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test.dart'));
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test2.dart'));
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test3.dart'));
      tracker.done();

      /// now test the replay
      var replay = FailedTracker.beginReplay(trackerFilename);

      expect(replay.fileExists, isFalse);
      expect(replay.backupExists, isTrue);
      expect(replay.testsToRetry.length, equals(3));

      // restart replay without calling done to
      // ensure we restore failed tests from the
      // backup.
      replay = FailedTracker.beginReplay(trackerFilename);

      expect(replay.fileExists, isFalse);
      expect(replay.backupExists, isTrue);
      expect(replay.testsToRetry.length, equals(3));
      replay.done();
      expect(replay.fileExists, isFalse);
      expect(replay.backupExists, isFalse);
    });
  });

  test('FailedTracker.beginReplay with second round', () {
    withTempFile((trackerFilename) {
      final tracker = FailedTracker.beginTestRun(trackerFilename);
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test.dart'));
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test2.dart'));
      tracker.recordFailure(UnitTest(pathTo: 'test/me/failed_test3.dart'));
      tracker.done();
      expect(tracker.failedTests.length, equals(3));

      /// now test the replay
      final replay = FailedTracker.beginReplay(trackerFilename);

      expect(replay.fileExists, isFalse);
      expect(replay.backupExists, isTrue);
      expect(replay.testsToRetry.length, equals(3));

      replay.recordFailure(UnitTest(pathTo: 'test/me/failed_test.dart'));
      expect(replay.failedTests.length, equals(1));

      replay.done();

      /// test a second replay after the last test had a failure
      final part2 = FailedTracker.beginReplay(trackerFilename);

      expect(part2.testsToRetry.length, equals(1));
      expect(part2.fileExists, isFalse);
      expect(part2.backupExists, isTrue);

      part2.done();
    });
  });
}
