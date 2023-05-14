/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

@Timeout(Duration(minutes: 3))
library;

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('Run critical_test as a spawned process', () {
    withTempFile((logfile) {
      withTempFile((tracker) {
        final criticalTestExe = join('bin', 'critical_test.dart');
        'dart $criticalTestExe --tracker=$tracker --log-path=$logfile '
                '--tags="bad,debug"'
            .start(
                workingDirectory: pwd,
                nothrow: true,
                progress: Progress.devNull());
      });
    });
  });
}
