import 'dart:ffi' as native;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart';

String pathToCriticalTestConfig = join('tool', 'critical_test');

/// Keep one default log per user in a directory other users cannot write.
final String secureDefaultLogPath = createLogPath(_defaultLogBase());

Directory _defaultLogBase() {
  if (Platform.isWindows) {
    final profile = Platform.environment['USERPROFILE'];
    final appData = Platform.environment['LOCALAPPDATA'];
    if (profile == null || appData == null) {
      throw StateError('A user profile is required for the default log');
    }
    final profilePath = Directory(profile).resolveSymbolicLinksSync();
    final appDataPath = Directory(appData).resolveSymbolicLinksSync();
    if (!isWithin(profilePath, appDataPath)) {
      throw StateError('LOCALAPPDATA must be within the user profile');
    }
    return Directory(appDataPath);
  }

  final home = Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    throw StateError('HOME is required for the default log');
  }
  return Directory(home);
}

/// This is also used by security tests with an isolated user directory.
String createLogPath(Directory base) {
  final basePath = base.resolveSymbolicLinksSync();
  final privateBase = Directory(basePath);
  if (!Platform.isWindows && (privateBase.statSync().mode & 0x12) != 0) {
    throw StateError('The default log base is writable by other users');
  }

  final logDirectory = Directory(join(basePath, '.critical_test_logs'));
  final directoryType = FileSystemEntity.typeSync(
    logDirectory.path,
    followLinks: false,
  );
  if (directoryType == FileSystemEntityType.notFound) {
    if (Platform.isWindows) {
      logDirectory.createSync();
    } else {
      _createPrivatePosixDirectory(logDirectory.path);
    }
  } else if (directoryType != FileSystemEntityType.directory) {
    throw StateError('The default log directory is not a directory');
  }

  if (!Platform.isWindows) {
    if ((logDirectory.statSync().mode & 0x3f) != 0) {
      throw StateError('The default log directory is not private');
    }
  }

  final logPath = join(logDirectory.path, 'unit_test.log');
  final logType = FileSystemEntity.typeSync(logPath, followLinks: false);
  if (logType == FileSystemEntityType.notFound) {
    File(logPath).createSync(exclusive: true);
  } else if (logType != FileSystemEntityType.file) {
    throw StateError('The default log path is not a regular file');
  }
  return logPath;
}

void _createPrivatePosixDirectory(String path) {
  final nativePath = path.toNativeUtf8();
  try {
    final libc = native.DynamicLibrary.process();
    final int result;
    if (Platform.isMacOS) {
      final mkdir = libc
          .lookupFunction<
            native.Int32 Function(native.Pointer<Utf8>, native.Uint16),
            int Function(native.Pointer<Utf8>, int)
          >('mkdir');
      result = mkdir(nativePath, 0x1c0); // 0700
    } else {
      final mkdir = libc
          .lookupFunction<
            native.Int32 Function(native.Pointer<Utf8>, native.Uint32),
            int Function(native.Pointer<Utf8>, int)
          >('mkdir');
      result = mkdir(nativePath, 0x1c0); // 0700
    }
    if (result != 0 &&
        FileSystemEntity.typeSync(path, followLinks: false) !=
            FileSystemEntityType.directory) {
      throw FileSystemException('Could not create private log directory', path);
    }
  } finally {
    malloc.free(nativePath);
  }
}
