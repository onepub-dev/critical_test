#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:critical_test/src/main.dart';
import 'package:critical_test/src/version/version.g.dart';
import 'package:dcli/dcli.dart' hide run;

void main(List<String> args) async {
  print(orange('critical_test $packageVersion'));
  print('');
  await run(args);
}
