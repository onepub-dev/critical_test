/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:critical_test/src/unit_tests/failed_tracker.dart';
import 'package:critical_test/src/unit_tests/unit_test.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

final pathToTestOne = join('tests', 'one.dart');
final unitTestOne = UnitTest(pathTo: pathToTestOne, testName: 'one');

void main() {
  group('FailedTracker', () {
    test('simple ...', () async {
      await withTempDirAsync((dir) async{
        await withTempFileAsync((trackerFilename) async{
          final tracker = FailedTracker.beginTestRun(trackerFilename);
          expect(exists(trackerFilename), isFalse);
          tracker
            ..recordError(unitTestOne)
            ..done();
          expect(exists(trackerFilename), isTrue);
        }, create: false, pathToTempDir: dir);
      });
    });

    test('successful after failure.', () async {
      await withTempDirAsync((dir) async{
        await withTempFileAsync((trackerFilename) async{
          /// record a failed unit tests.
          final tracker = FailedTracker.beginTestRun(trackerFilename);
          expect(exists(trackerFilename), isFalse);
          expect(exists(tracker.backupFilename), isFalse);
          tracker
            ..recordError(unitTestOne)
            ..done();
          expect(exists(trackerFilename), isTrue);
          expect(exists(tracker.backupFilename), isFalse);

          // check the test is available for playback
          final replay = FailedTracker.beginReplay(trackerFilename);
          expect(exists(trackerFilename), isTrue);
          expect(exists(tracker.backupFilename), isTrue);

          final tests = replay.failedTests;
          expect(tests.length, equals(1));
          expect(tests.first.pathTo, equals(unitTestOne.pathTo));
          expect(tests.first.testName, equals(unitTestOne.testName));
          // mark the test as having succeeded.
          tracker
            ..recordSuccess(UnitTest(
                pathTo: unitTestOne.pathTo, testName: unitTestOne.testName))
            ..done();

          expect(exists(trackerFilename), isTrue);
          expect(exists(tracker.backupFilename), isFalse);

          /// check the sucessful test has been removed.

          final check = FailedTracker.beginReplay(trackerFilename);
          expect(exists(trackerFilename), isTrue);
          expect(exists(tracker.backupFilename), isTrue);

          final testsCheck = check.failedTests;
          expect(testsCheck.length, equals(0));
        }, create: false, pathToTempDir: dir);
      });
    });
  });
}
