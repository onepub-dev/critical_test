import 'package:critical_test/src/util/counts.dart';
import 'package:critical_test/src/process_output.dart' as po;
import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  /// Check that the .failed_tracker file contains the correct information.
  test('failed tracker', () async {
    // ct.CriticalTest.run(
    //     <String>['--single', 'test_scripts/for_counts_test.dart']);

    var pathToFailedTracker = po.failedTrackerFilename;
    if (exists(pathToFailedTracker)) delete(pathToFailedTracker);

    withTempFile((logfile) {
      final progress = start(
          'critical_test --logPath=$logfile --single ${join('test_scripts', 'for_counts_test.dart')}',
          progress: Progress.capture(),
          nothrow: true,
          runInShell: true);

      var counts = lastCounts(progress.lines);
      expect(exists(pathToFailedTracker), isTrue);
      expect(counts.errors, 2);
      expect(progress.exitCode!, equals(1));

      var failedTests = read(pathToFailedTracker).toList();
      expect(failedTests.length, equals(1));
      expect(
          failedTests[0], equals(join('test_scripts', 'for_counts_test.dart')));
    });
  });
}
