/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

class Counts {
  var success = 0;

  var errors = 0;

  var _skipped = 0;

  Counts();

  Counts.withValues(this.success, this.errors, int skipped)
      : _skipped = skipped;

  Counts.copyFrom(Counts counts) {
    success = counts.success;
    errors = counts.errors;
    _skipped = counts._skipped;
  }

  void incSkipped() {
    _skipped++;
  }

  int get skipped => _skipped;

  bool get allPassed => errors == 0;

  bool get nothingRan => success == 0 && errors == 0;

  @override
  String toString() =>
      'Success: ${green('$success')}, Errors: ${red('$errors')}, '
      'Skipped: ${blue('$skipped')}';
}

/// Takes a list of all the progress messages and finds
/// the last line which containts the counts.
/// It then parses the counts and returns the result
/// in the Counts object.
Counts lastCounts(List<String> lines) {
  for (var line in lines.reversed) {
    line = Ansi.strip(line);
    final regexWithErrors =
        RegExp('.+Errors: ([0-9]*), Success: ([0-9]*), Skipped: ([0-9]*)');

    if (regexWithErrors.hasMatch(line)) {
      final errors = regexWithErrors.firstMatch(line)!.group(1);
      final success = regexWithErrors.firstMatch(line)!.group(2);
      final skipped = regexWithErrors.firstMatch(line)!.group(3);

      return Counts.withValues(
          int.parse(success!), int.parse(errors!), int.parse(skipped!));
    }

    final regexNoErrors = RegExp('.+Success: ([0-9]*), Skipped: ([0-9]*)');

    if (regexNoErrors.hasMatch(line)) {
      final success = regexNoErrors.firstMatch(line)!.group(1);
      final skipped = regexNoErrors.firstMatch(line)!.group(2);

      return Counts.withValues(int.parse(success!), 0, int.parse(skipped!));
    }
  }
  throw Exception('No counts found');
}
