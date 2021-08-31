import 'package:dcli/dcli.dart';

String prehookPath(String pathToPackageRoot) =>
    join(pathToPackageRoot, 'tool', 'critical_test', 'pre_hook');
String posthookPath(String pathToPackageRoot) =>
    join(pathToPackageRoot, 'tool', 'critical_test', 'post_hook');

void runPreHooks(String pathToPackageRoot) =>
    runHooks(prehookPath(pathToPackageRoot), pathToPackageRoot, 'pre_hook');
void runPostHooks(String pathToPackageRoot) =>
    runHooks(posthookPath(pathToPackageRoot), pathToPackageRoot, 'post_hook');

void runHooks(String pathToHook, String pathToPackageRoot, String type) {
  if (exists(pathToHook)) {
    var hooks =
        find('*', workingDirectory: pathToHook, recursive: false).toList();
    hooks.sort((lhs, rhs) => lhs.compareTo(rhs));
    if (hooks.isEmpty) {
      print(orange('No $type found in $pathToHook.'));
    }

    for (var file in hooks) {
      if (isFile(file)) {
        if (_isIgnoredFile(file)) return;
        if (isExecutable(file)) {
          print('Running $type $file');
          runHook(file, pathToPackageRoot, args: <String>[]);
        } else {
          print(orange('Skipping non-executable $type $file'));
        }
      } else {
        Settings().verbose('Ignoring non-file $type $file');
      }
    }
  } else {
    print(blue("The critical_test $type directory $pathToHook doesn't exist."));
  }
}

void runHook(String pathToHook, String pathToPackageRoot,
    {required List<String> args}) {
  if (extension(pathToHook) == '.dart') {
    /// incase dcli isn't installed.
    DartSdk()
        .run(args: [pathToHook, ...args], workingDirectory: pathToPackageRoot);
  } else {
    '$pathToHook ${args.join(' ')}'.start(workingDirectory: pathToPackageRoot);
  }
}

const _ignoredExtensions = ['.yaml', '.ini', '.config', '.ignore'];
bool _isIgnoredFile(String pathToHook) {
  final _extension = extension(pathToHook);

  return _ignoredExtensions.contains(_extension);
}
