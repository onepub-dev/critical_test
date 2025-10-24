/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:settings_yaml/settings_yaml.dart';

import 'arg_handler.dart';
import 'paths.dart';

/// stores configuration details for critical_test
///
/// You can use the config to set default command line arguments.
/// If the user passes in the command line arguments then the
/// override the configured ones.
///

class Settings {
  // Settings.load() {
  //   var pathTo = defaultPath;

  //   yaml = _loadFromPath(pathTo: pathTo);
  // }

  static const filename = 'settings.yaml';

  late final SettingsYaml yaml;

  static String defaultPath = join(pathToCriticalTestConfig, filename);

  Settings.loadFromPath({required String pathTo}) {
    yaml = _loadFromPath(pathTo: pathTo);
  }

  List<String> get excludeTags => yaml.asStringList('exclude-tags');

  List<String> get tags => yaml.asStringList('tags');

  String get plainName => yaml.asString('plain-name');

  bool get showAll => yaml.asBool('all', defaultValue: false);

  bool get progress => yaml.asBool('progress');

  bool get coverage => yaml.asBool('coverage', defaultValue: false);

  String get logPath => yaml.asString('log-path', defaultValue: defaultLogPath);

  bool get noHooks => yaml.asBool('no-hooks', defaultValue: false);

  bool get warmup => yaml.asBool('warmup');

  bool get track => yaml.asBool('track');

  SettingsYaml _loadFromPath({required String pathTo}) {
    final parent = dirname(pathTo);
    if (!exists(parent)) {
      createDir(parent, recursive: true);
    }
    return SettingsYaml.load(pathToSettings: pathTo);
  }
}
