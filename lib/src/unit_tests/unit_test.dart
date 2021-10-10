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
  UnitTest({this.pathTo, this.testName})
      : assert(pathTo != null || testName != null);
  String? pathTo;
  String? testName;

  factory UnitTest.fromJson(Map<String, dynamic> json) =>
      _$UnitTestFromJson(json);

  bool get hasTestName => testName != null;

  // /// Returns the unit test name if it has one.
  // /// Call [hasName] before calling this method to determine
  // /// if this [UnitTest] has a name.
  // String get name {
  //   var name = '';

  //   if (testName != null) {
  //     name = ' $testName';
  //   }
  //   return name;
  // }

  @override
  String toString() {
    var result = '';

    if (testName != null) result += 'test: "$testName", ';
    if (pathTo != null) result += pathTo!;

    return result;
  }

  Map<String, dynamic> toJson() => _$UnitTestToJson(this);

  static List<UnitTest> decodeList(String source) {
    var l = json.decode(source) as Iterable;
    return List<UnitTest>.from(l.map<UnitTest>(
        (dynamic i) => UnitTest.fromJson(i as Map<String, dynamic>)));
  }

  static List<UnitTest> fromFile(String failedTrackerFilename) {
    var source = read(failedTrackerFilename).toParagraph();
    return UnitTest.decodeList(source);
  }
}
