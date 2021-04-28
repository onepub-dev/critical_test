import 'package:critical_test/src/process_output.dart' hide test;
import 'package:test/test.dart';
import 'package:dcli/dcli.dart' hide equals;

void main() {
  test('process output ...', () async {
    /// we must set a log path.
    var logPath = join(createTempDir(), 'logfile.log');
    logToPath = logPath;
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
  });
}
