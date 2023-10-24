// ignore_for_file: non_constant_identifier_names

import 'package:changelog_bubbler/src/config_manager.dart';
import 'package:changelog_bubbler/src/template/template.dart';

class TemplateManager {
  /// The top level template
  late final Template root_template;

  /// Second level template used for dependency groups
  late final Template dependency_group_template;

  /// Lowest level template used for templating an added or deleted dependency
  late final Template dependency_added_or_removed_template;

  /// Lowest level template used for templating a changed dependency
  late final Template dependency_changed_template;

  /// Used when the app update had no dependency changes
  late final Template no_changed_dependencies_template;

  final ConfigManager _configManager;
  TemplateManager(this._configManager);

  void init() {
    root_template = Template(
      _configManager.root_template,
    );
    dependency_added_or_removed_template = Template(
      _configManager.dependency_added_or_removed_template,
    );
    dependency_changed_template = Template(
      _configManager.dependency_changed_template,
    );
    dependency_group_template = Template(
      _configManager.dependency_group_template,
    );
    no_changed_dependencies_template = Template(
      _configManager.no_changed_dependencies_template,
    );
  }
}
