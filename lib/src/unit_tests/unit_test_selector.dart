import 'package:critical_test/src/unit_tests/unit_test.dart';

/// Describes a unit test or the collection of unit tests in a test library.
/// To run all unit tests in a file just pass in [pathTo]
/// To run a single test pass in the [testName].
/// If the test name is nested with a group(s) then the test name
/// should include the group name(s).
/// e.g.
/// <group name> <test name>
///
class UnitTestSelector {
  UnitTestSelector.fromUnitTest(UnitTest unitTest)
      : pathTo = unitTest.pathTo,
        testName = unitTest.testName;

  UnitTestSelector.fromPath({required this.pathTo});
  UnitTestSelector.fromTestName({required this.testName});

  String? pathTo;
  String? testName;

  @override
  String toString() {
    var result = '';

    result += 'test: "${testName ?? '*'}", ';
    result += pathTo ?? '';

    return result;
  }
}
