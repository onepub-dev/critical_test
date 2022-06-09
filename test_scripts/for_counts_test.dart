/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:test/test.dart';

void main() {
  group('Group ##1', () {
    test('Intentional fail', () {
      fail('intentionally failed');
    }, tags: ['bad']);

    test('Intentional succeed', () {
      expect(1, equals(1));
    });

    test('2nd Intentional fail', () {
      fail('intentionally failed');
    }, tags: ['bad']);

    test('2nd Intentional succeed', () {
      expect(1, equals(1));
    });

    test('skipped1', () {
      expect(1, equals(1));
    }, skip: true);

    test('skipped2', () {
      expect(1, equals(1));
    }, skip: true);

    test('3rd Intentional succeed', () {
      expect(1, equals(1));
    });

    test('4th Intentional succeed', () {
      expect(1, equals(1));
    });
  });
}
