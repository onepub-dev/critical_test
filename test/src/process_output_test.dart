import 'package:critical_test/src/process_output.dart' hide test;
import 'package:test/test.dart';
import 'package:dcli/dcli.dart' hide equals;

void main() {
  test('process output ...', () async {
    /// we must set a log path.
    var logPath = join(createTempDir(), 'logfile.log');
    print('logging to $logPath');
    logToPath = logPath;
    activeScript = 'testScript';

    // logPath.truncate();
    var expectedMessage = 'Hellow world';
    processOutput(
        '''{"message": "$expectedMessage","type":"print","time":4187}''');
//     var log = read(logPath).toList();
    expect(lines.isNotEmpty, isTrue);
    expect(lines.first, equals(expectedMessage));

    // logPath.truncate();
    var crap = 'and some crap';
    processOutput(
        '''{"message": "$expectedMessage","type":"print","time":4187}$crap''');

    // log = read(logPath).toList();
    expect(lines.isNotEmpty, isTrue);
    expect(lines.first, equals(expectedMessage));
    expect(lines[1], equals(crap));

    processOutput(
        '{"testID":3,"result":"success","skipped":false,"hidden":false,"type":"testDone","time":2414}');
    var log = read(logPath).toList();
    expect(log[2], equals('1:0:0:0 testScript: Completed '));
  });
}
