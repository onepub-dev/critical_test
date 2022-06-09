@Timeout(Duration(minutes: 5))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */



import 'package:critical_test/critical_test.dart';
import 'package:critical_test/src/unit_tests/failed_tracker.dart';
import 'package:test/test.dart';
import 'package:dcli/dcli.dart' hide equals;

void main() {
  test('process output ...', () async {
    var processor = ProcessOutput();
    processor.showProgress = false;

    /// we must set a log path.
    var _logPath = join(createTempDir(), 'logfile.log');
    print('logging to $_logPath');
    processor.logPath = _logPath;

    final tracker = FailedTracker.ignoreFailures();

    final path = join(rootPath, 'home', 'bsutton', 'git', 'critical_test',
        'test_scripts', 'for_counts_test.dart');

    final escapedPath = path.replaceAll(r'\', '/');
    processor.processOutput(
        '{"test":{"id":11,"name":"Group ##1 4th Intentional succeed","suiteID":0,"groupIDs":[2,3],"metadata":{"skip":false'
        ',"skipReason":null},"line":33,"column":5,"url":"file://$escapedPath"},"type":"testStart","time":1011}',
        tracker);

    var expectedMessage = 'Hellow world';
    processor.processOutput(
        '''{"message": "${expectedMessage}1","type":"print","time":4187}''',
        tracker);
    expect(processor.lines.isNotEmpty, isTrue);
    expect(processor.lines.first, equals('${expectedMessage}1'));

    var crap = 'and some crap';
    processor.processOutput(
        '''{"message": "${expectedMessage}2","type":"print","time":4187}$crap''',
        tracker);

    expect(processor.lines.isNotEmpty, isTrue);
    expect(processor.lines.first, equals('${expectedMessage}1'));
    expect(processor.lines[1], equals(crap));

    processor.processOutput(
        r'{"testID":3,"result":"success","skipped":false,"hidden":false,"type":"testDone","time":2414}',
        tracker);
    processor.processOutput(
        r'{"testID":4,"result":"success","skipped":false,"hidden":false,"type":"testDone","time":2414}',
        tracker);

    final log = read(_logPath).toList();
    // final uriPath = Uri.parse('file://${relative(escapedPath)}').toFilePath();
    expect(
        log.first,
        equals(
            '0:0:0 Running: ${relative(escapedPath)} : Group ##1 4th Intentional succeed'));
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
