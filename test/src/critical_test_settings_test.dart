/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:critical_test/src/critical_test_settings.dart';
import 'package:dcli/dcli.dart' hide equals, Settings;
import 'package:test/test.dart';

void main() {
  test('critical test settings ...', () async {
    withTempFile((pathTosettings) {
      pathTosettings.write('''
exclude-tags: [sudo]
tags: [fred]
plain-name: Test Me
all: false
progress: true
coverage: false
log-path: /tmp/some/path
hooks: true
warmup: false
track: true''');

      var settings = Settings.loadFromPath(pathTo: pathTosettings);

      expect(settings.excludeTags, equals(['sudo']));
      expect(settings.tags, equals(['fred']));
      expect(settings.plainName, equals('Test Me'));
      expect(settings.showAll, isFalse);
      expect(settings.progress, isTrue);
      expect(settings.coverage, isFalse);
      expect(settings.logPath, equals('/tmp/some/path'));
      expect(settings.hooks, isTrue);
      expect(settings.warmup, isFalse);
      expect(settings.track, isTrue);
    });
  });
}
