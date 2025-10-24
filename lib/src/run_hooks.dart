/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

import 'paths.dart';

String prehookPath(String pathToPackageRoot) =>
    join(pathToPackageRoot, pathToCriticalTestConfig, 'pre_hook');
String posthookPath(String pathToPackageRoot) =>
    join(pathToPackageRoot, pathToCriticalTestConfig, 'post_hook');

void runPreHooks(String pathToPackageRoot) => runHooks(
    prehookPath(pathToPackageRoot), pathToPackageRoot, HookType.pre_hook);
void runPostHooks(String pathToPackageRoot) => runHooks(
    posthookPath(pathToPackageRoot), pathToPackageRoot, HookType.post_hook);

void runHooks(String pathToHook, String pathToPackageRoot, HookType type) {
  if (exists(pathToHook)) {
    final hooks = find('*', workingDirectory: pathToHook, recursive: false)
        .toList()
      ..sort((lhs, rhs) => lhs.compareTo(rhs));
    if (hooks.isEmpty) {
      print(orange('No ${type.name} found in $pathToHook.'));
    }

    for (final file in hooks) {
      if (isFile(file)) {
        if (_isIgnoredFile(file)) {
          return;
        }
        if (isExecutable(file)) {
          print('Running ${type.name} $file');
          runHook(file, pathToPackageRoot, type, args: <String>[]);
        } else {
          print(orange('Skipping non-executable ${type.name} $file'));
        }
      } else {
        Settings().verbose('Ignoring non-file ${type.name} $file');
      }
    }
  } else {
    print(blue(
        "The critical_test ${type.name} directory $pathToHook doesn't exist."));
  }
}

void runHook(String pathToHook, String pathToPackageRoot, HookType hookType,
    {required List<String> args}) {
  final Progress progress;
  if (extension(pathToHook) == '.dart') {
    /// incase dcli isn't installed.
    progress = DartSdk().run(
        args: [pathToHook, ...args],
        workingDirectory: pathToPackageRoot,
        nothrow: true);
  } else {
    progress = '$pathToHook ${args.join(' ')}'
        .start(workingDirectory: pathToPackageRoot, nothrow: true);
  }

  if (progress.exitCode != 0) {
    printerr(red('The ${hookType.name} returned with an non-zero exit code '
        '${progress.exitCode}. Testing terminated '));
    exit(progress.exitCode!);
  }
}

// designed to match the directory name.
// ignore: constant_identifier_names
enum HookType { pre_hook, post_hook }

const _ignoredExtensions = ['.yaml', '.ini', '.config', '.ignore'];
bool _isIgnoredFile(String pathToHook) {
  final extension0 = extension(pathToHook);

  return _ignoredExtensions.contains(extension0);
}
