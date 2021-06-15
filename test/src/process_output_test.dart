import 'package:critical_test/critical_test.dart' hide test;
import 'package:test/test.dart';
import 'package:dcli/dcli.dart' hide equals;

void main() {
  test('process output ...', () async {
    /// we must set a log path.
    var _logPath = join(createTempDir(), 'logfile.log');
    print('logging to $_logPath');
    logPath = _logPath;
    activeScript = 'testScript';

    final tracker = FailedTracker.ignoreFailures();
    // logPath.truncate();
    var expectedMessage = 'Hellow world';
    processOutput(
        '''{"message": "$expectedMessage","type":"print","time":4187}''',
        tracker);
//     var log = read(logPath).toList();
    expect(lines.isNotEmpty, isTrue);
    expect(lines.first, equals(expectedMessage));

    // logPath.truncate();
    var crap = 'and some crap';
    processOutput(
        '''{"message": "$expectedMessage","type":"print","time":4187}$crap''',
        tracker);

    // log = read(logPath).toList();
    expect(lines.isNotEmpty, isTrue);
    expect(lines.first, equals(expectedMessage));
    expect(lines[1], equals(crap));

    processOutput(
        '{"testID":3,"result":"success","skipped":false,"hidden":false,"type":"testDone","time":2414}',
        tracker);
    processOutput(
        '{"testID":4,"result":"success","skipped":false,"hidden":false,"type":"testDone","time":2414}',
        tracker);

    var log = read(_logPath).toList();
    expect(log.last, equals('2:0:0 testScript: Completed '));
  });

  test('pass by reference', () {
    var counts = Counts();

    addOne(counts);
    expect(counts.success, equals(1));
  });
}

void addOne(Counts counts) {
  counts.success++;
}
