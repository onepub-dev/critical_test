import 'package:critical_test/src/util/counts.dart';
import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('check test counts', () async {
    // ct.CriticalTest.run(
    //     <String>['--single', 'test_scripts/for_counts_test.dart']);

    final progress = start(
        'critical_test --logPath=\dev\null --single test_scripts/for_counts_test.dart',
        progress: Progress.capture(),
        nothrow: true);

    // print(progress.lines.join('\n'));
    var counts = lastCounts(progress.lines);

    expect(counts.success, 4);
    expect(counts.errors, 2);
    expect(counts.skipped, 2);
    expect(progress.exitCode!, equals(1));
  });

  test('check test counts with tags', () async {
    // ct.CriticalTest.run(
    //     <String>['--single', 'test_scripts/for_counts_test.dart']);

    final progress = start(
        'critical_test --logPath=\dev\null --single test_scripts/for_counts_test.dart --tags="!bad"',
        progress: Progress.capture(),
        nothrow: true);

    // print(progress.lines.join('\n'));
    var counts = lastCounts(progress.lines);

    expect(counts.success, 4);
    expect(counts.errors, 0);
    expect(counts.skipped, 2);

    expect(progress.exitCode!, equals(0));
  });

  test('check test counts with exclude-tags', () async {
    // ct.CriticalTest.run(
    //     <String>['--single', 'test_scripts/for_counts_test.dart']);

    final progress = start(
        'critical_test --logPath=\dev\null --single test_scripts/for_counts_test.dart --exclude-tags="bad"',
        progress: Progress.capture(),
        nothrow: true);

    // print(progress.lines.join('\n'));
    var counts = lastCounts(progress.lines);

    expect(counts.success, 4);
    expect(counts.errors, 0);
    expect(counts.skipped, 2);
    expect(progress.exitCode!, equals(0));
  });

  test('skip mee', () {}, skip: true);
}
