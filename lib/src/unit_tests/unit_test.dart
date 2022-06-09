
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:convert';

import 'package:dcli/dcli.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unit_test.g.dart';

/// Describes a unit test or a file with unit tests.
/// To run all unit tests in a file just pass in [pathTo]
/// To run a single test passing in the [testName].
/// If the test name is nested with a group(s) then the test name
/// should include the group name(s).
/// e.g.
/// <group name> <test name>
///
/// To generate the json
/// pub global activate build_runner
/// dart run build_runner build
@JsonSerializable()
class UnitTest {
  UnitTest({required this.pathTo, required this.testName});
  final String pathTo;
  final String testName;

  factory UnitTest.fromJson(Map<String, dynamic> json) =>
      _$UnitTestFromJson(json);

  @override
  String toString() {
    var result = '';

    result += 'test: "$testName", ';
    result += pathTo;

    return result;
  }

  Map<String, dynamic> toJson() => _$UnitTestToJson(this);

  static List<UnitTest> decodeList(String source) {
    var l = json.decode(source) as Iterable;
    return List<UnitTest>.from(l.map<UnitTest>(
        (dynamic i) => UnitTest.fromJson(i as Map<String, dynamic>)));
  }

  static List<UnitTest> loadFailedTests(String failedTrackerFilename) {
    var source = read(failedTrackerFilename).toParagraph();
    if (source.trim().isEmpty) {
      return <UnitTest>[];
    } else {
      return UnitTest.decodeList(source);
    }
  }

  /// Used so we can create a menu item to exit
  /// critical_test without running any unit test.
  const UnitTest.exitOption()
      : pathTo = '',
        testName = 'exit';
}
