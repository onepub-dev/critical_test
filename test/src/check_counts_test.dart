/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:critical_test/src/util/counts.dart';
import 'package:dcli/dcli.dart' hide  run;
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('check test counts', () async {
    // ct.CriticalTest.run(
    //     <String>['test_scripts/for_counts_test.dart']);

    withTempFile((logfile) {
      withTempFile((tracker) {
        final criticalTestExe = join('bin', 'critical_test.dart');
        final progress = start(
            '$criticalTestExe --tracker=$tracker --log-path=$logfile  '
            '${join('test_scripts', 'for_counts_test.dart')}',
            progress: Progress.capture(),
            nothrow: true,
            runInShell: true);

        // print(progress.lines.join('\n'));
        final counts = lastCounts(progress.lines);

        expect(counts.success, 4);
        expect(counts.errors, 2);
        expect(counts.skipped, 2);
        expect(progress.exitCode, equals(1));
      });
    });
  });

  // test('check test counts -direct', () async {
  //   // ct.CriticalTest.run(
  //   //     <String>['test_scripts/for_counts_test.dart']);

  //   withTempFile((logfile) {
  //     withTempFile((tracker) {
  //       run([
  //         '--tracker=$tracker',
  //         '--log-path=$logfile',
  //         'test_scripts/for_counts_test.dart'
  //       ]);
  //     });
  //   });
  // });

  test('check test counts with tags', () async {
    // ct.CriticalTest.run(
    //     <String>['test_scripts/for_counts_test.dart']);

    withTempFile((logfile) {
      withTempFile((tracker) {
        final criticalTestExe = join('bin', 'critical_test.dart');
        final progress = DartSdk().run(
          args: [
            criticalTestExe,
            '--tracker=$tracker',
            '--log-path=$logfile',
            '--tags=!bad',
            '-v',
            join('test_scripts', 'for_counts_test.dart')
          ],
          progress: Progress.capture(),
          nothrow: true,
        );

        // print(progress.lines.join('\n'));
        final counts = lastCounts(progress.lines);

        expect(counts.success, 4);
        expect(counts.errors, 0);
        expect(counts.skipped, 2);

        expect(progress.exitCode, equals(0));
      });
    });
  });

  test('check test counts with exclude-tags', () async {
    // ct.CriticalTest.run(
    //     <String>['test_scripts/for_counts_test.dart']);

    withTempFile((logfile) {
      withTempFile((tracker) {
        final criticalTestExe = join('bin', 'critical_test.dart');
        final progress = DartSdk().run(
          args: [
            criticalTestExe,
            '--tracker=$tracker',
            '--log-path=$logfile',
            '--exclude-tags=bad',
            join('test_scripts', 'for_counts_test.dart')
          ],
          progress: Progress.capture(),
          nothrow: true,
        );

        // print(progress.lines.join('\n'));
        final counts = lastCounts(progress.lines);

        expect(counts.success, 4);
        expect(counts.errors, 0);
        expect(counts.skipped, 2);
        expect(progress.exitCode, equals(0));
      });
    });
  });

  test('skip mee', () {}, skip: true);
}
