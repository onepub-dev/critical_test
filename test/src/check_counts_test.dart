@Timeout(Duration(minutes: 2))
import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

// void main() {
//   test('check test counts', () async {
//     late Progress progress;

//     progress = await DCliZone().run(() {
//       try {
//         ct.CriticalTest.run(
//             <String>['--single', '../test_script/for_counts_test.dart']);
//       } on CriticalTestException catch (e) {
//         printerr(e.message);
//       }
//       print('returning');
//     }, progress: Progress.capture());

//     print(progress.lines.join('\n'));
//   });
// }

void main() {
  test('check test counts', () async {
    // ct.CriticalTest.run(
    //     <String>['--single', 'test_scripts/for_counts_test.dart']);

    final progress = start(
        'critical_test --single test_scripts/for_counts_test.dart',
        progress: Progress.capture(),
        nothrow: true);

    // print(progress.lines.join('\n'));
    var counts = lastCounts(progress.lines);

    expect(counts.success, 4);
    expect(counts.failure, 2);
    expect(counts.errors, 0);
    expect(counts.skipped, 2);
    expect(progress.exitCode!, equals(255));
  });

  test('check test counts with tags', () async {
    // ct.CriticalTest.run(
    //     <String>['--single', 'test_scripts/for_counts_test.dart']);

    final progress = start(
        'critical_test --single test_scripts/for_counts_test.dart --tags="!bad"',
        progress: Progress.capture(),
        nothrow: true);

    // print(progress.lines.join('\n'));
    var counts = lastCounts(progress.lines);

    expect(counts.success, 4);
    expect(counts.failure, 0);
    expect(counts.errors, 0);
    expect(counts.skipped, 2);

    expect(progress.exitCode!, equals(0));
  });

  test('check test counts with exclude-tags', () async {
    // ct.CriticalTest.run(
    //     <String>['--single', 'test_scripts/for_counts_test.dart']);

    final progress = start(
        'critical_test --single test_scripts/for_counts_test.dart --exclude-tags="bad"',
        progress: Progress.capture(),
        nothrow: true);

    // print(progress.lines.join('\n'));
    var counts = lastCounts(progress.lines);

    expect(counts.success, 4);
    expect(counts.failure, 0);
    expect(counts.errors, 0);
    expect(counts.skipped, 2);
    expect(progress.exitCode!, equals(0));
  });
}

Counts lastCounts(List<String> lines) {
  for (final line in lines.reversed) {
    var regex = RegExp('([0-9]*):([0-9]*):([0-9]*):([0-9]*).+');
    if (regex.hasMatch(line)) {
      var success = regex.firstMatch(line)!.group(1);
      var failure = regex.firstMatch(line)!.group(2);
      var errors = regex.firstMatch(line)!.group(3);
      var skipped = regex.firstMatch(line)!.group(4);

      return Counts(int.parse(success!), int.parse(failure!),
          int.parse(errors!), int.parse(skipped!));
    }
  }
  throw Exception('Not counts found');
}

class Counts {
  Counts(this.success, this.failure, this.errors, this.skipped);
  int success;
  int failure;
  int errors;
  int skipped;
}
