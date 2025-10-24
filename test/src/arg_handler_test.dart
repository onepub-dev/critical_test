/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:critical_test/src/arg_handler.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group('tags', () {
    test('tags - single tag', ()  {
      final args = ['--tags=solo'];
      final parsedArgs = ParsedArgs.build()..parse(args);
      expect(parsedArgs.tags, equals(['solo']));
    });

    test('tags - two tags', ()  {
      final two = ['--tags=eins,zwei'];
      final parsedArgs = ParsedArgs.build()..parse(two);
      expect(parsedArgs.tags, equals(['eins', 'zwei']));
    });

    test('tags - from settings.', () async {
       await withTempFileAsync((pathToSettings) async {
        pathToSettings.write('''
tags: [abc, one]      
      ''');

        final parsedArgs = ParsedArgs.build()
          ..parse(['--settings-path=$pathToSettings']);
        expect(parsedArgs.tags, equals(['abc', 'one']));
      });
    });

    test('tags - override settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
tags: [abc, one]      
      ''');
        final args = ['--tags=solo', '--settings-path=$pathToSettings'];
        final parsedArgs = ParsedArgs.build()..parse(args);
        expect(parsedArgs.tags, equals(['solo']));
      });
    });
  });

  group('exclude-tags', () {
    test('single ', ()  {
      final args = ['--exclude-tags=solo'];
      final parsedArgs = ParsedArgs.build()..parse(args);
      expect(parsedArgs.excludeTags, equals(['solo']));
    });

    test('two', ()  {
      final two = ['--exclude-tags=eins,zwei'];
      final parsedArgs = ParsedArgs.build()..parse(two);
      expect(parsedArgs.excludeTags, equals(['eins', 'zwei']));
    });

    test('from settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
exclude-tags: [abc, one]      
      ''');

        final parsedArgs = ParsedArgs.build()
          ..parse(['--settings-path=$pathToSettings']);
        expect(parsedArgs.excludeTags, equals(['abc', 'one']));
      });
    });

    test(' override settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
tags: [abc, one]      
      ''');
        final args = ['--exclude-tags=solo', '--settings-path=$pathToSettings'];
        final parsedArgs = ParsedArgs.build()..parse(args);
        expect(parsedArgs.excludeTags, equals(['solo']));
      });
    });
  });

  group('plan-name', () {
    test('none', ()  {
      final parsedArgs = ParsedArgs.build()..parse([]);
      expect(parsedArgs.plainName, equals(''));
    });

    test('named', ()  {
      final two = ['--plain-name=Test One'];
      final parsedArgs = ParsedArgs.build()..parse(two);
      expect(parsedArgs.plainName, equals('Test One'));
    });

    test('from settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
plain-name: Test Two      
      ''');

        final parsedArgs = ParsedArgs.build()
          ..parse(['--settings-path=$pathToSettings']);
        expect(parsedArgs.plainName, equals('Test Two'));
      });
    });

    test(' override settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
plain-name: Test Two       
      ''');
        final args = ['--plain-name=fancy', '--settings-path=$pathToSettings'];
        final parsedArgs = ParsedArgs.build()..parse(args);
        expect(parsedArgs.plainName, equals('fancy'));
      });
    });
  });

  group('showAll', () {
    test('default', ()  {
      final parsedArgs = ParsedArgs.build()..parse([]);
      expect(parsedArgs.showAll, false);
    });

    test('arg', ()  {
      final two = ['--all'];
      final parsedArgs = ParsedArgs.build()..parse(two);
      expect(parsedArgs.showAll, isTrue);
    });

    test('from settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
all: true
      ''');

        final parsedArgs = ParsedArgs.build()
          ..parse(['--settings-path=$pathToSettings']);
        expect(parsedArgs.showAll, isTrue);
      });
    });

    test(' override settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
all: true       
      ''');
        final args = ['--settings-path=$pathToSettings'];
        final parsedArgs = ParsedArgs.build()..parse(args);
        expect(parsedArgs.showAll, isTrue);
      });
    });

    group('progress', () {
      test('default', ()  {
        final parsedArgs = ParsedArgs.build()..parse([]);
        expect(parsedArgs.showProgress, true);
      });

      test('arg', ()  {
        final two = ['--progress'];
        final parsedArgs = ParsedArgs.build()..parse(two);
        expect(parsedArgs.showProgress, isTrue);
      });

      test('from settings.', () async {
        await withTempFileAsync((pathToSettings) async{
          pathToSettings.write('''
progress: true
      ''');

          final parsedArgs = ParsedArgs.build()
            ..parse(['--settings-path=$pathToSettings']);
          expect(parsedArgs.showProgress, isTrue);
        });
      });

      test(' override settings.', () async {
        await withTempFileAsync((pathToSettings) async{
          pathToSettings.write('''
progress: true       
      ''');
          final args = ['--no-progress', '--settings-path=$pathToSettings'];
          final parsedArgs = ParsedArgs.build()..parse(args);
          expect(parsedArgs.showProgress, isFalse);
        });
      });
    });
  });

  group('coverage', () {
    test('default', ()  {
      final parsedArgs = ParsedArgs.build()..parse([]);
      expect(parsedArgs.coverage, false);
    });

    test('arg', ()  {
      final two = ['--coverage'];
      final parsedArgs = ParsedArgs.build()..parse(two);
      expect(parsedArgs.coverage, isTrue);
    });

    test('from settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
coverage: true
      ''');

        final parsedArgs = ParsedArgs.build()
          ..parse(['--settings-path=$pathToSettings']);
        expect(parsedArgs.coverage, isTrue);
      });
    });

    test(' override settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
coverage: true       
      ''');
        final args = ['--no-coverage', '--settings-path=$pathToSettings'];
        final parsedArgs = ParsedArgs.build()..parse(args);
        expect(parsedArgs.coverage, isFalse);
      });
    });
  });

  group('hooks', () {
    test('default', ()  {
      final parsedArgs = ParsedArgs.build()..parse([]);
      expect(parsedArgs.runHooks, true);
    });

    test('arg', ()  {
      final two = ['--no-hooks'];
      final parsedArgs = ParsedArgs.build()..parse(two);
      expect(parsedArgs.runHooks, isFalse);
    });

    test('from settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
hooks: true
      ''');

        final parsedArgs = ParsedArgs.build()
          ..parse(['--settings-path=$pathToSettings']);
        expect(parsedArgs.runHooks, isTrue);
      });
    });

    test(' override settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
hooks: true       
      ''');
        final args = ['--no-hooks', '--settings-path=$pathToSettings'];
        final parsedArgs = ParsedArgs.build()..parse(args);
        expect(parsedArgs.runHooks, isFalse);
      });
    });
  });

  group('warmup', () {
    test('default', ()  {
      final parsedArgs = ParsedArgs.build()..parse([]);
      expect(parsedArgs.warmup, true);
    });

    test('arg', ()  {
      final two = ['--warmup'];
      final parsedArgs = ParsedArgs.build()..parse(two);
      expect(parsedArgs.warmup, isTrue);
    });

    test('from settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
warmup: false
      ''');

        final parsedArgs = ParsedArgs.build()
          ..parse(['--settings-path=$pathToSettings']);
        expect(parsedArgs.warmup, isFalse);
      });
    });

    test(' override settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
warmup: true       
      ''');
        final args = ['--no-warmup', '--settings-path=$pathToSettings'];
        final parsedArgs = ParsedArgs.build()..parse(args);
        expect(parsedArgs.warmup, isFalse);
      });
    });
  });

  group('track', () {
    test('default', ()  {
      final parsedArgs = ParsedArgs.build()..parse([]);
      expect(parsedArgs.track, isTrue);
    });

    test('arg', ()  {
      final two = ['--track'];
      final parsedArgs = ParsedArgs.build()..parse(two);
      expect(parsedArgs.track, isTrue);
    });

    test('from settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
track: false
      ''');

        final parsedArgs = ParsedArgs.build()
          ..parse(['--settings-path=$pathToSettings']);
        expect(parsedArgs.track, isFalse);
      });
    });

    test(' override settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        pathToSettings.write('''
track: false       
      ''');
        final args = ['--track', '--settings-path=$pathToSettings'];
        final parsedArgs = ParsedArgs.build()..parse(args);
        expect(parsedArgs.track, isTrue);
      });
    });
  });

  group('log-path', () {
    test('default', ()  {
      final parsedArgs = ParsedArgs.build()..parse([]);
      expect(parsedArgs.logPath, equals(defaultLogPath));
    });

    test('override', ()  {
      final two = ['--log-path=/tmp/hello'];
      final parsedArgs = ParsedArgs.build()..parse(two);
      expect(parsedArgs.logPath, equals(join(rootPath, 'tmp', 'hello')));
    });

    test('from settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        final logPath = join(rootPath, 'tmp', 'hello');
        pathToSettings.write('''
log-path: $logPath      
      ''');

        final parsedArgs = ParsedArgs.build()
          ..parse(['--settings-path=$pathToSettings']);
        expect(parsedArgs.logPath, equals(logPath));
      });
    });

    test(' override settings.', () async {
      await withTempFileAsync((pathToSettings) async{
        final logPath = join(rootPath, 'tmp', 'hello');
        pathToSettings.write('''
log-path: $logPath        
      ''');
        final args = ['--log-path=$logPath', '--settings-path=$pathToSettings'];
        final parsedArgs = ParsedArgs.build()..parse(args);
        expect(parsedArgs.logPath, equals(logPath));
      });
    });
  });
}
