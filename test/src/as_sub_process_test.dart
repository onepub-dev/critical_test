@Timeout(Duration(minutes: 3))
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('Run critical_test as a spawned process', () {
    'critical_test --tags="bad"'.start(workingDirectory: pwd, nothrow: true);
  });
}
