import 'dart:io';

import 'package:changelog_bubbler/src/dependency_parser.dart';
import 'package:changelog_bubbler/src/dependency_type.dart';
import 'package:changelog_bubbler/src/package_wrapper.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

class DiffBuilder {
  /// Holds the parsed dependencies for the repo in the current state
  final DependencyParser current;

  /// Holds the parsed dependencies for the repo in the previous state
  final DependencyParser previous;

  /// The name of the changelog we should be searching for
  ///   This can be a value passed by the user. Check CLI input for defaults.
  final String changelogName;

  DiffBuilder({
    required this.previous,
    required this.current,
    required this.changelogName,
  });

  Future<String> buildDiff() async {
    return _fullOutputTemplate
        .replaceFirst('{{main_app}}', _buildMainAppSection())
        .replaceFirst('{{dependency_groups}}', _buildGroups());
  }

  String _buildGroups() {
    // Find the packages that have changed
    final changedDeps = {...current.dependencies, ...previous.dependencies}
      ..removeWhere((key, value) => previous.dependencies[key]?.sameVersion(value) == true)
      ..removeWhere((key, value) => current.dependencies[key]?.sameVersion(value) == true);
    final sortedDeps = changedDeps.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    // We will build the diff by section
    // Each section will be for a separate hosted location
    // Gather the unique urls for hosted dependencies
    final urlSet = sortedDeps.map((e) => e.value.trimmedUrl).whereNotNull().toSet();

    final groupsBySection = StringBuffer();
    for (final groupUrl in urlSet) {
      final depsInGroup = sortedDeps.where((e) => e.value.trimmedUrl == groupUrl);
      if (depsInGroup.isEmpty) {
        continue;
      }
      final groupBuffer = StringBuffer();
      for (final dependencyType in DependencyType.sorted) {
        final depsOfDepType = depsInGroup.where((e) => e.value.dependencyType == dependencyType);
        if (depsOfDepType.isEmpty) {
          continue;
        }
        for (final dep in depsOfDepType) {
          final previousDep = previous.dependencies.entries.firstWhereOrNull((e) => e.key == dep.key);
          final currentDep = current.dependencies.entries.firstWhereOrNull((e) => e.key == dep.key);

          groupBuffer.write(_buildPackageDiff(
            previous: previousDep,
            current: currentDep,
          ));
        }
      }
      groupsBySection.write(
        _groupTemplate
            .replaceFirst('{{group_name}}', groupUrl)
            .replaceFirst('{{packages_in_group}}', groupBuffer.toString()),
      );
    }

    if (groupsBySection.isEmpty) {
      return _emptyDependenciesTemplate;
    }

    return groupsBySection.toString();
  }

  String _buildMainAppSection() {
    return _mainPackageDiffTemplate
        .replaceFirst(
          '{{package_name}}',
          previous.pubspec.name,
        )
        .replaceFirst(
          '{{previous_version}}',
          previous.pubspec.version.toString(),
        )
        .replaceFirst(
          '{{current_version}}',
          current.pubspec.version.toString(),
        )
        .replaceFirst(
          '{{changelog_diff}}',
          _getChangelogDiff(
            currentPath: current.repoPath,
            previousPath: previous.repoPath,
          ),
        );
  }

  String _buildPackageDiff({
    required MapEntry<String, PackageWrapper>? previous,
    required MapEntry<String, PackageWrapper>? current,
  }) {
    assert(previous != null || current != null, 'Either previous or current must not be null');
    if (previous == null) {
      return _depAddedOrRemovedTemplate
          .replaceFirst('{{package_name}}', current!.key)
          .replaceFirst('{{dependency_type}}', current.value.dependencyType.name)
          .replaceFirst('{{change_type}}', 'ADDED');
    }
    if (current == null) {
      return _depAddedOrRemovedTemplate
          .replaceFirst('{{package_name}}', previous.key)
          .replaceFirst('{{dependency_type}}', previous.value.dependencyType.name)
          .replaceFirst('{{change_type}}', 'REMOVED');
    }

    return _depDiffTemplate
        .replaceFirst('{{package_name}}', previous.key)
        .replaceFirst('{{previous_version}}', previous.value.package.version.toString())
        .replaceFirst('{{current_version}}', current.value.package.version.toString())
        .replaceFirst('{{dependency_type}}', current.value.dependencyType.name)
        .replaceFirst(
          '{{changelog_diff}}',
          _getChangelogDiff(
            previousPath: previous.value.getPubCachePath(),
            currentPath: current.value.getPubCachePath(),
          ),
        );
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

  static const _fullOutputTemplate = '''
# Bubbled Changelog

## This app
{{main_app}}

## Changed Dependencies

{{dependency_groups}}
''';

  static const _groupTemplate = '''
### {{group_name}}

{{packages_in_group}}
''';

  static const _emptyDependenciesTemplate = '''
$_paddedDivStart
No changed dependencies
$_divEnd
''';

  static const _mainPackageDiffTemplate = '''
{{package_name}} | {{previous_version}} -> {{current_version}}

$_paddedDivStart
{{changelog_diff}}
$_divEnd
''';
  static const _depDiffTemplate = '''
{{package_name}} | {{previous_version}} -> {{current_version}} | {{dependency_type}}

$_paddedDivStart
{{changelog_diff}}
$_divEnd
''';
  static const _depAddedOrRemovedTemplate = '''
{{package_name}} | {{change_type}} | {{dependency_type}}
''';

  static const _paddedDivStart = '<div style="padding-left: 2em; padding-bottom: 1em;">';
  static const _divEnd = '</div>';
}
