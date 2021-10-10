@Timeout(Duration(minutes: 3))
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('Run critical_test as a spawned process', () {
    withTempFile((logfile) {
      withTempFile((tracker) {
        'bin/critical_test.dart --tracker=$tracker --logPath=$logfile --tags="bad,debug"'
            .start(
                workingDirectory: pwd,
                nothrow: true,
                progress: Progress.devNull());
      });
    });
  });
}
