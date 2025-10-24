/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

/// Class used to decode the 'test' types emmited by the dart unit tests
/// json reporter
class Test {
// An opaque ID for the test.
  int id;

// The name of the test, including prefixes from any containing groups.
  String name;

// The ID of the suite containing this test.
  int suiteID;

// The (1-based) line on which the test was defined, or `null`.
  int line;

// The (1-based) column on which the test was defined, or `null`.
  int column;

// The URL for the file in which the test was defined, or `null`.
  String url;

  Test(this.id, this.name, this.line, this.column, this.url, this.suiteID) {
    if (name.startsWith('loading')) {
      /// we already display the active script so lets not repeat it.
      name = 'Loading.';
    }
    if (name.startsWith('Completed loading')) {
      /// we already display the active script so lets not repeat it.
      name = 'Completed loading.';
    }
  }

  Test.empty()
      : id = 0,
        name = '',
        line = 0,
        column = 0,
        url = '',
        suiteID = 0;

  factory Test.fromJson(Map<String, dynamic> json) => Test(
      json['id'] as int,
      json['name'] as String,
      json['line'] as int? ?? 0,
      json['column'] as int? ?? 0,
      json['url'] as String? ?? '',
      json['suiteid'] as int? ?? 0);

  String get path => Uri.parse(url).toFilePath();

  // // The (1-based) line in the original test suite from which the test
  // // originated.
  // //
  // // Will only be present if `root_url` is different from `url`.
  // int root_line;

  // // The (1-based) line on in the original test suite from which the test
  // // originated.
  // //
  // // Will only be present if `root_url` is different from `url`.
  // int root_column;

  // // The URL for the original test suite in which the test was defined.
  // //
  // // Will only be present if different from `url`.
  // String root_url;
}
