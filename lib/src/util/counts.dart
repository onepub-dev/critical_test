import 'package:dcli/dcli.dart';

class Counts {
  Counts();
  Counts.withValues(this.success, this.errors, int skipped)
      : _skipped = skipped;
  int success = 0;
  int errors = 0;
  int _skipped = 0;

  void incSkipped() {
    _skipped++;
  }

  int get skipped => _skipped;

  bool get allPassed => errors == 0;

  bool get nothingRan => success == 0 && errors == 0;

  // void add(int success, int failures, int errors, int skipped) {
  //   this.success += success;
  //   this.failures += failures;
  //   this.errors += errors;
  //   this.skipped += skipped;
  // }

  // void add(Counts counts) {
  //   success += counts.success;
  //   errors += counts.errors;
  //   skipped += counts.skipped;
  // }

  Counts.copyFrom(Counts counts) {
    success = counts.success;
    errors = counts.errors;
    _skipped = counts._skipped;
  }

  @override
  String toString() {
    return 'Success: ${green('$success')}, Errors: ${red('$errors')}, Skipped: ${blue('$skipped')}';
  }
}

/// Takes a list of all the progress messages and finds
/// the last line containt counts.
/// It then parses the counts and returns the result
/// in the Counts object.
Counts lastCounts(List<String> lines) {
  for (final line in lines.reversed) {
    var regex = RegExp('([0-9]*):([0-9]*):([0-9]*).+');
    if (regex.hasMatch(line)) {
      var success = regex.firstMatch(line)!.group(1);
      var errors = regex.firstMatch(line)!.group(2);
      var skipped = regex.firstMatch(line)!.group(3);

      return Counts.withValues(
          int.parse(success!), int.parse(errors!), int.parse(skipped!));
    }
  }
  throw Exception('Not counts found');
}
