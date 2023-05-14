@Timeout(Duration(minutes: 5))
library;
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:critical_test/src/exceptions/critical_test_exception.dart';
import 'package:critical_test/src/main.dart';
import 'package:critical_test/src/process_output.dart';
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  /// test case used when we need to debug.
  test('check test counts', () async {
    // progress = await DCliZone().run(() {
    final processor = ProcessOutput();
    try {
      withTempFile((trackerFile) {
        withTempFile((logFile) {
          CriticalTest.run(<String>[
            '--tracker=$trackerFile',
            r'--log-path=$logFile',
            '-v',
            '--track',
            '--plain-name="Group ##1 Intentional fail"',
            'test_scripts',
          ], processor);
        });
      });

      //CriticalTest.run(<String>['test_scripts'], processor);
    } on CriticalTestException catch (e) {
      printerr(e.message);
    }
    print('returning');
    //  }, progress: Progress.capture());

    // print(progress.lines.join('\n'));
  }, tags: ['special']);
}
