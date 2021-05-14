@Timeout(Duration(minutes: 5))
import 'package:critical_test/src/exceptions/critical_test_exception.dart';
import 'package:critical_test/src/main.dart';
import 'package:critical_test/src/util/counts.dart';
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  /// test case used when we need to debug.
  test('check test counts', () async {
    late Progress progress;

    // progress = await DCliZone().run(() {
    var counts = Counts();
    try {
      // CriticalTest.run(<String>['--exclude-tags=special'], counts);
      CriticalTest.run(<String>['--single=test_scripts'], counts);
    } on CriticalTestException catch (e) {
      printerr(e.message);
    }
    print('returning');
    //  }, progress: Progress.capture());

    // print(progress.lines.join('\n'));
  }, tags: ['special']);
}
