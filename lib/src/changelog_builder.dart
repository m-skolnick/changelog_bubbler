import 'dart:convert';
import 'dart:io';

import 'package:changelog_bubbler/src/change_manager.dart';
import 'package:changelog_bubbler/src/dependency_pair.dart';
import 'package:changelog_bubbler/src/template_manager.dart';
import 'package:path/path.dart' as p;

class ChangelogBuilder {
  // Manages the differences between the previous dependencies and current
  final ChangeManager changeManager;

  /// The name of the changelog we should be searching for
  ///   This can be a value passed by the user. Check CLI input for defaults.
  final String changelogName;

  /// The top level template
  final TemplateManager changelogTemplate;

  /// Second level template used for dependency groups
  final TemplateManager depGroupTemplate;

  /// Lowest level template used for templating a changed dependency
  final TemplateManager depChangedTemplate;

  /// Lowest level template used for templating an added or deleted dependency
  final TemplateManager depAddedOrRemovedTemplate;

  /// Used when the app update had no dependency changes
  final TemplateManager noChangedDependenciesTemplate;

  ChangelogBuilder({
    required this.changeManager,
    required this.changelogName,
    required this.changelogTemplate,
    required this.depGroupTemplate,
    required this.depChangedTemplate,
    required this.depAddedOrRemovedTemplate,
    required this.noChangedDependenciesTemplate,
  });

  String buildJsonOutput() {
    final changedDepsList =
        changeManager.changedDeps.map((e) => e.toJson()).toList();
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(changedDepsList);
  }

  Future<String> buildChangelogFromTemplates() async {
    return changelogTemplate.replaceAll({
      '{{root_package_name}}': changeManager.previous.pubspec.name,
      '{{root_previous_version}}':
          changeManager.previous.pubspec.version.toString(),
      '{{root_current_version}}':
          changeManager.current.pubspec.version.toString(),
      '{{root_changelog_diff}}': _getChangelogDiff(
        currentPath: changeManager.current.repoPath,
        previousPath: changeManager.previous.repoPath,
      ),
      '{{dependency_groups}}': _buildGroupsFromTemplate(),
    });
  }

  String _buildGroupsFromTemplate() {
    final stringBuffer = StringBuffer();

    if (changeManager.groups.isEmpty) {
      return noChangedDependenciesTemplate.unalteredTemplate;
    }

    for (final group in changeManager.groups.entries) {
      final dependencyListBuffer = StringBuffer();
      for (final depPair in group.value) {
        dependencyListBuffer.write(_buildInvidualDepFromTemplate(depPair));
      }
      final substitutedTemplate = depGroupTemplate.replaceAll({
        '{{group_name}}': group.key,
        '{{changed_dependencies}}': dependencyListBuffer.toString(),
      });

      stringBuffer.write(substitutedTemplate);
    }

    return stringBuffer.toString();
  }

  String _buildInvidualDepFromTemplate(DependencyPair depPair) {
    final current = depPair.current;
    final previous = depPair.previous;

    if (current != null && previous != null) {
      return depChangedTemplate.replaceAll({
        '{{package_name}}': depPair.name,
        '{{previous_version}}': previous.version.toString(),
        '{{current_version}}': current.version.toString(),
        '{{dependency_type}}': depPair.dependencyType.name,
        '{{changelog_diff}}': _getChangelogDiff(
          previousPath: previous.getPubCachePath(),
          currentPath: current.getPubCachePath(),
        ),
      });
    }

    return depAddedOrRemovedTemplate.replaceAll({
      '{{package_name}}': depPair.name,
      '{{change_type}}': depPair.changeType.name,
      '{{dependency_type}}': depPair.dependencyType.name,
    });
  }

  String _getChangelogDiff({
    required String previousPath,
    required String currentPath,
  }) {
    final previousChangelog = File(p.join(previousPath, changelogName));
    final currentChangelog = File(p.join(currentPath, changelogName));

    if (!previousChangelog.existsSync() || !currentChangelog.existsSync()) {
      return '$changelogName not found';
    }
    final previousString = previousChangelog.readAsStringSync();
    final currentString = currentChangelog.readAsStringSync();
    final diff = currentString.replaceFirst(previousString, '');
    if (diff.isEmpty) {
      return '$changelogName did not contain changes';
    }

    return diff;
  }
}
