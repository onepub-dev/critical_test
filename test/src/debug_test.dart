@Timeout(Duration(minutes: 5))
import 'package:critical_test/src/exceptions/critical_test_exception.dart';
import 'package:critical_test/src/main.dart';
import 'package:critical_test/src/process_output.dart';
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  /// test case used when we need to debug.
  test('check test counts', () async {
    // progress = await DCliZone().run(() {
    var processor = ProcessOutput();
    try {
      CriticalTest.run(<String>[
        r'--tracker=C:\Users\Brett\AppData\Local\Temp\a2332afb-576f-4b46-846a-d10560419633.tmp',
        r'--logPath=C:\Users\Brett\AppData\Local\Temp\8440525c-fd27-40e5-86c0-db8394430b1d.tmp',
        '-v',
        '--track',
        '--plain-name="Group ##1 Intentional fail"',
        'test_scripts',
      ], processor);

      //CriticalTest.run(<String>['test_scripts'], processor);
    } on CriticalTestException catch (e) {
      printerr(e.message);
    }
    print('returning');
    //  }, progress: Progress.capture());

    // print(progress.lines.join('\n'));
  }, tags: ['special']);
}
