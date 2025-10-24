/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:path/path.dart';

import '../arg_handler.dart';
import 'unit_test.dart';

/// Describes a unit test or the collection of unit tests in a test library.
/// To run all unit tests in a file just pass in [testPaths]
/// To run a single test pass in the [testName].
/// If the test name is nested with a group(s) then the test name
/// should include the group name(s).
/// e.g.
/// `<group name> <test name>`
///
class UnitTestSelector {
  /// The set of directories and/or libraries to run tests from.
  final List<String> testPaths;

  String? testName;

  List<String> tags;

  List<String> excludeTags;

  UnitTestSelector.fromArgs(ParsedArgs parsedArgs)
      : testPaths = List.from(parsedArgs.parsed.rest),
        testName = parsedArgs.plainName,
        tags = parsedArgs.tags,
        excludeTags = parsedArgs.excludeTags {
    if (testPaths.isEmpty) {
      // by default tests are run in the 'test' directory
      testPaths.add(join(parsedArgs.pathToProjectRoot, 'test'));
    }
  }

  UnitTestSelector.fromUnitTest(UnitTest unitTest)
      : testName = unitTest.testName,
        testPaths = <String>[],
        tags = <String>[],
        excludeTags = <String>[] {
    testPaths.add(unitTest.pathTo);
  }

  UnitTestSelector.fromPath(
      {required this.testPaths, required this.tags, required this.excludeTags});

  UnitTestSelector.fromTestName({required this.testName})
      : testPaths = <String>[],
        tags = <String>[],
        excludeTags = <String>[];

  @override
  String toString() {
    var result = '';

    result += 'test: "${testName ?? '*'}", ';
    result += testPaths.join(', ');

    return result;
  }
}
