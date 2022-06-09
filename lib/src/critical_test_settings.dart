/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:critical_test/critical_test.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:settings_yaml/settings_yaml.dart';

import 'arg_handler.dart';

/// stores configuration details for critical_test
///
/// You can use the config to set default command line arguments.
/// If the user passes in the command line arguments then the override the configured ones.
///

class Settings {
  static const filename = 'settings.yaml';

  late final SettingsYaml yaml;

  static String defaultPath = join(pathToCriticalTestConfig, filename);

  // Settings.load() {
  //   var pathTo = defaultPath;

  //   yaml = _loadFromPath(pathTo: pathTo);
  // }

  Settings.loadFromPath({required String pathTo}) {
    yaml = _loadFromPath(pathTo: pathTo);
  }

  List<String> get excludeTags => yaml.asStringList('exclude-tags');
  List<String> get tags => yaml.asStringList('tags');
  String get plainName => yaml.asString('plain-name');
  bool get showAll => yaml.asBool('all', defaultValue: false);
  bool get progress => yaml.asBool('progress', defaultValue: true);
  bool get coverage => yaml.asBool('coverage', defaultValue: false);
  String get logPath => yaml.asString('log-path', defaultValue: defaultLogPath);
  bool get hooks => yaml.asBool('hooks', defaultValue: false);
  bool get warmup => yaml.asBool('warmup');
  bool get track => yaml.asBool('track');

  SettingsYaml _loadFromPath({required String pathTo}) {
    var parent = dirname(pathTo);
    if (!exists(parent)) createDir(parent, recursive: true);
    return SettingsYaml.load(pathToSettings: pathTo);
  }
}
