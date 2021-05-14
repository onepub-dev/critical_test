@Timeout(Duration(minutes: 3))
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('Run critical_test as a spawned process', () {
    'critical_test --logPath=/dev/null --tags="bad,debug"'.start(
        workingDirectory: pwd, nothrow: true, progress: Progress.devNull());
  });
}
