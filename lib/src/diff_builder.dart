import 'dart:io';

import 'package:changelog_bubbler/src/dependency_parser.dart';
import 'package:changelog_bubbler/src/package_extensions.dart';
import 'package:collection/collection.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';
import 'package:path/path.dart' as p;

class DiffBuilder {
  /// Holds the parsed dependencies for the repo in the current state
  final DependencyParser parserCurrent;

  /// Holds the parsed dependencies for the repo in the previous state
  final DependencyParser parserPrevious;

  /// The name of the changelog we should be searching for
  ///   This can be a value passed by the user. Check CLI input for defaults.
  final String changelogName;

  DiffBuilder({
    required this.parserPrevious,
    required this.parserCurrent,
    required this.changelogName,
  });

  Future<String> buildDiff() async {
    return _fullOutputTemplate
        .replaceFirst('{{main_app}}', _getMainAppSection())
        .replaceFirst('{{dependency_groups}}', _getSections());
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

  String _getSections() {
    // We will build the diff by section
    // Each section will be for a separate hosted location
    // Gather the unique urls for hosted dependencies
    final allDeps = {...parserCurrent.dependencies, ...parserPrevious.dependencies}.entries.toList();
    allDeps.sort((a, b) => a.key.compareTo(b.key));
    Set<String> uniqueUrls = {};
    Set<String> uniqueDependencyTypes = {};
    for (final entry in allDeps) {
      uniqueDependencyTypes.add(entry.value.dependency);
      final url = entry.value.trimmedUrl;
      if (url != null) {
        uniqueUrls.add(url);
      }
    }

    final groupsBySection = StringBuffer();
    for (final groupUrl in uniqueUrls) {
      final depsInGroup = allDeps.where((e) => e.value.trimmedUrl == groupUrl);
      if (depsInGroup.isEmpty) {
        continue;
      }
      final groupBuffer = StringBuffer();
      for (final dependencyType in uniqueDependencyTypes) {
        final depsOfDepType = depsInGroup.where((e) => e.value.dependency == dependencyType);

        for (final dep in depsOfDepType) {
          final previousDep = parserPrevious.dependencies.entries.firstWhereOrNull((e) => e.key == dep.key);
          final currentDep = parserCurrent.dependencies.entries.firstWhereOrNull((e) => e.key == dep.key);

          groupBuffer.write(_getPackageDiff(
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

    return groupsBySection.toString();
  }

  String _getMainAppSection() {
    return _depDiffTemplate
        .replaceFirst(
          '{{package_name}}',
          parserPrevious.pubspec.name,
        )
        .replaceFirst(
          '{{previous_version}}',
          parserPrevious.pubspec.version.toString(),
        )
        .replaceFirst(
          '{{current_version}}',
          parserCurrent.pubspec.version.toString(),
        )
        .replaceFirst(
          '{{changelog_diff}}',
          _getChangelogDiff(
            currentPath: parserCurrent.repoPath,
            previousPath: parserPrevious.repoPath,
          ),
        );
  }

  String _getPackageDiff({
    required MapEntry<String, Package>? previous,
    required MapEntry<String, Package>? current,
  }) {
    assert(previous != null || current != null, 'Either previous or current must not be null');
    if (previous == null) {
      return _depAddedOrRemovedTemplate
          .replaceFirst('{{package_name}}', current!.key)
          .replaceFirst('{{dependency_type}}', current.value.dependency)
          .replaceFirst('{{change_type}}', 'ADDED');
    }
    if (current == null) {
      return _depAddedOrRemovedTemplate
          .replaceFirst('{{package_name}}', previous.key)
          .replaceFirst('{{dependency_type}}', previous.value.dependency)
          .replaceFirst('{{change_type}}', 'REMOVED');
    }

    return _depDiffTemplate
        .replaceFirst('{{package_name}}', previous.key)
        .replaceFirst('{{previous_version}}', previous.value.version.toString())
        .replaceFirst('{{current_version}}', current.value.version.toString())
        .replaceFirst('{{dependency_type}}', current.value.dependency)
        .replaceFirst(
          '{{changelog_diff}}',
          _getChangelogDiff(
            previousPath: previous.value.getPubCachePath(name: previous.key),
            currentPath: current.value.getPubCachePath(name: current.key),
          ),
        );
  }

  static const _fullOutputTemplate = '''
# Bubbled Changelog

{{main_app}}

{{dependency_groups}}
''';

  static const _groupTemplate = '''
## {{group_name}}

{{packages_in_group}}
''';

  static const _depDiffTemplate = '''
{{package_name}} | {{dependency_type}} | {{previous_version}} -> {{current_version}}

{{changelog_diff}}

''';
  static const _depAddedOrRemovedTemplate = '''
{{package_name}} | {{dependency_type}} | {{change_type}}
''';
}
