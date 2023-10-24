import 'dart:convert';
import 'dart:io';

import 'package:changelog_bubbler/src/change_manager.dart';
import 'package:changelog_bubbler/src/dependency_pair.dart';
import 'package:changelog_bubbler/src/template/template_manager.dart';
import 'package:path/path.dart' as p;

class ChangelogBuilder {
  // Manages the differences between the previous dependencies and current
  final ChangeManager _changeManager;

  /// The name of the changelog we should be searching for
  ///   This can be a value passed by the user. Check CLI input for defaults.
  final String _changelogName;

  /// Manages all templates, and where the templates are loaded from
  final TemplateManager _templateManager;

  ChangelogBuilder({
    required ChangeManager changeManager,
    required TemplateManager templateManager,
    required String changelogName,
  })  : _changeManager = changeManager,
        _templateManager = templateManager,
        _changelogName = changelogName;

  String buildJsonOutput() {
    final changedDepsList =
        _changeManager.changedDeps.map((e) => e.toJson()).toList();
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(changedDepsList);
  }

  Future<String> buildChangelogFromTemplates() async {
    return _templateManager.root_template.replaceAll({
      '{{root_package_name}}': _changeManager.previous.pubspec.name,
      '{{root_previous_version}}':
          _changeManager.previous.pubspec.version.toString(),
      '{{root_current_version}}':
          _changeManager.current.pubspec.version.toString(),
      '{{root_changelog_diff}}': _getChangelogDiff(
        currentPath: _changeManager.current.repoPath,
        previousPath: _changeManager.previous.repoPath,
      ),
      '{{dependency_groups}}': _buildGroupsFromTemplate(),
    });
  }

  String _buildGroupsFromTemplate() {
    final stringBuffer = StringBuffer();

    if (_changeManager.groups.isEmpty) {
      return _templateManager
          .no_changed_dependencies_template.unalteredTemplate;
    }

    for (final group in _changeManager.groups.entries) {
      final dependencyListBuffer = StringBuffer();
      for (final depPair in group.value) {
        dependencyListBuffer.write(_buildInvidualDepFromTemplate(depPair));
      }
      final substitutedTemplate =
          _templateManager.dependency_group_template.replaceAll({
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
      return _templateManager.dependency_changed_template.replaceAll({
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

    return _templateManager.dependency_added_or_removed_template.replaceAll({
      '{{package_name}}': depPair.name,
      '{{change_type}}': depPair.changeType.name,
      '{{dependency_type}}': depPair.dependencyType.name,
    });
  }

  String _getChangelogDiff({
    required String previousPath,
    required String currentPath,
  }) {
    final previousChangelog = File(p.join(previousPath, _changelogName));
    final currentChangelog = File(p.join(currentPath, _changelogName));

    if (!previousChangelog.existsSync() || !currentChangelog.existsSync()) {
      return '$_changelogName not found';
    }
    final previousString = previousChangelog.readAsStringSync();
    final currentString = currentChangelog.readAsStringSync();
    final diff = currentString.replaceFirst(previousString, '');
    if (diff.isEmpty) {
      return '$_changelogName did not contain changes';
    }

    return diff;
  }
}
