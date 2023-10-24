// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class ConfigManager {
  late final String root_template;
  late final String dependency_added_or_removed_template;
  late final String dependency_changed_template;
  late final String dependency_group_template;
  late final String no_changed_dependencies_template;

  late final String _bundlePath;
  late final String _workingDir;
  late final YamlMap? _workingDirYaml;
  late final YamlMap _bundledYaml;
  final _configFileName = 'changelog_bubbler.yaml';

  void loadConfig({required String workingDir}) {
    _workingDir = workingDir;
    _workingDirYaml = _getWorkingDirYaml();
    _bundledYaml = _getBundledYaml();

    loadConfigValues();
  }

  @visibleForTesting
  void loadConfigValues() {
    root_template = _formTemplatePath(
      'root_template',
    );
    dependency_added_or_removed_template = _formTemplatePath(
      'dependency_added_or_removed_template',
    );
    dependency_changed_template = _formTemplatePath(
      'dependency_changed_template',
    );
    dependency_group_template = _formTemplatePath(
      'dependency_group_template',
    );
    no_changed_dependencies_template = _formTemplatePath(
      'no_changed_dependencies_template',
    );
  }

  String _formTemplatePath(String pathKey) {
    final pathFromCurrentDirYaml =
        _workingDirYaml?['template-paths']?[pathKey] as String?;
    if (pathFromCurrentDirYaml != null) {
      return pathFromCurrentDirYaml;
    }

    // If the value is not overridden by the user
    //    form the path using the bundle path and the value from our bundled config
    return p.join(
      _bundlePath,
      _bundledYaml['template-paths'][pathKey] as String,
    );
  }

  YamlMap? _getWorkingDirYaml() {
    final yamlFromWorkingDir = File(p.join(
      _workingDir,
      _configFileName,
    ));

    if (!yamlFromWorkingDir.existsSync()) {
      print(
        'No $_configFileName found in $_workingDir. Proceeding with default configs.',
      );
      return null;
    }
    return loadYaml(yamlFromWorkingDir.readAsStringSync()) as YamlMap;
  }

  YamlMap _getBundledYaml() {
    // If we're using the bundled yaml, we need to do
    // some file path manipulation to resolve the uri to the asset folder
    // inside the changelog_bubbler package
    _bundlePath = File(Platform.script.toFilePath()).parent.parent.path;
    final yamlFromBundle = File(p.join(_bundlePath, _configFileName));

    if (!yamlFromBundle.existsSync()) {
      throw Exception('Failed to load $_configFileName');
    }

    return loadYaml(yamlFromBundle.readAsStringSync()) as YamlMap;
  }
}