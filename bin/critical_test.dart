#! /usr/bin/env dcli

import 'dart:io';

import 'package:critical_test/src/exceptions/critical_test_exception.dart';
import 'package:critical_test/src/main.dart';
import 'package:critical_test/src/util/counts.dart';
import 'package:dcli/dcli.dart';

/// running unit tests from vs-code doesn't seem to work as it spawns
/// two isolates and runs tests in parallel (even when using the -j1 option)
/// Given we are actively modifying the file system this is a bad idea.
/// So this script forces the test to run serially via the -j1 option.
///
void main(List<String> args) {
  try {
    var counts = Counts();
    CriticalTest.run(args, counts);

    if (!counts.allPassed) {
      exit(1);
    }
    if (counts.nothingRan) {
      exit(5);
    }
  } on CriticalTestException catch (e) {
    printerr(e.message);
    exit(1);
  }

  exit(0);
}
