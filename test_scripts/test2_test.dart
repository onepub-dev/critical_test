import 'package:test/test.dart';

void main() {
  group('Test2', () {
    test('Intentional fail', () {
      fail('intentionally failed');
    });
    test('Intentional succeed', () {
      expect(1, equals(1));
    });

    test(
        '2nd Intentional fail  - with a very very very very very very very very very very very very very very very very very very very very very long name',
        () {
      fail('intentionally failed');
    });

    test('2nd Intentional succeed', () {
      expect(1, equals(1));
    });

    test('skipped', () {
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
