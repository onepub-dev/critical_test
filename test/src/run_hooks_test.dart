@Timeout(Duration(minutes: 5))
import 'dart:io';

import 'package:critical_test/src/run_hooks.dart';
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('hooks ...', () async {
    withTempDir((packageRoot) {
      final pathToHooks =
          join(packageRoot, 'tool', 'critical_test', 'pre_hook');
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
  chmod(500, pathToScript);

  return pathToScript;
}

String createSh(String pathToHooks) {
  final pathToScript = join(pathToHooks, 'test.sh');
  const body = '''
echo 'hello' 
''';

  pathToScript.write(body);

  // make script executable
  chmod(500, pathToScript);

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
