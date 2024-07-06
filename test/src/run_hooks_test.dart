@Timeout(Duration(minutes: 5))
library;
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:critical_test/src/paths.dart';
import 'package:critical_test/src/run_hooks.dart';
import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('hooks ...', () async {
    withTempDir((packageRoot) {
      final pathToHooks =
          join(packageRoot, pathToCriticalTestConfig, 'pre_hook');
      createDir(pathToHooks, recursive: true);

      createDart(pathToHooks);

      if (Platform.isWindows) {
        createBat(pathToHooks);
      } else {
        createSh(pathToHooks);
      }

      runPreHooks(packageRoot);
    });
  });
}

String createDart(String pathToHooks) {
  final pathToScript = join(pathToHooks, 'test.dart');
  const body = '''
void main()      
{
  print('hello');
}
''';

  pathToScript.write(body);

  // make script executable
  chmod(pathToScript, permission: '500');

  return pathToScript;
}

String createSh(String pathToHooks) {
  final pathToScript = join(pathToHooks, 'test.sh');
  const body = '''
echo 'hello' 
''';

  pathToScript.write(body);

  // make script executable
  chmod(pathToScript, permission: '500');

  return pathToScript;
}

String createBat(String pathToHooks) {
  final pathToScript = join(pathToHooks, 'test.bat');
  const body = '''
echo 'hello' 
''';

  pathToScript.write(body);

  return pathToScript;
}
