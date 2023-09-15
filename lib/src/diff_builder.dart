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
    return _fullOutputStr(
      mainApp: _buildMainAppSection(),
      dependencyGroups: _buildGroups(),
    );
  }

  String _buildGroups() {
    // Find the packages that have changed
    final changedDeps =
        {...current.dependencies, ...previous.dependencies}.entries.where((e) {
      return previous.dependencies[e.key]?.sameVersion(e.value) != true ||
          current.dependencies[e.key]?.sameVersion(e.value) != true;
    });
    final sortedDeps = changedDeps.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    // We will build the diff by section
    // Each section will be for a separate hosted location
    // Gather the unique urls for hosted dependencies
    final urlSet =
        sortedDeps.map((e) => e.value.trimmedUrl).whereNotNull().toSet();

    final groupsBySection = StringBuffer();
    for (final groupUrl in urlSet) {
      final depsInGroup =
          sortedDeps.where((e) => e.value.trimmedUrl == groupUrl);
      if (depsInGroup.isEmpty) {
        continue;
      }
      final groupBuffer = StringBuffer();
      for (final dependencyType in DependencyType.sorted) {
        final depsOfDepType =
            depsInGroup.where((e) => e.value.dependencyType == dependencyType);
        if (depsOfDepType.isEmpty) {
          continue;
        }
        for (final dep in depsOfDepType) {
          final previousDep = previous.dependencies.entries
              .firstWhereOrNull((e) => e.key == dep.key);
          final currentDep = current.dependencies.entries
              .firstWhereOrNull((e) => e.key == dep.key);

          groupBuffer.write(_buildPackageDiff(
            previous: previousDep,
            current: currentDep,
          ));
        }
      }
      groupsBySection.write(
        _groupStr(
          groupName: groupUrl,
          packagesInGroup: groupBuffer.toString(),
        ),
      );
    }

    if (groupsBySection.isEmpty) {
      return _emptyDependencyStr();
    }

    return groupsBySection.toString();
  }

  String _buildMainAppSection() {
    return _mainPackageDiffStr(
      packageName: previous.pubspec.name,
      previousVersion: previous.pubspec.version.toString(),
      currentVersion: current.pubspec.version.toString(),
      changelogDiff: _getChangelogDiff(
        currentPath: current.repoPath,
        previousPath: previous.repoPath,
      ),
    );
  }

  String _buildPackageDiff({
    required MapEntry<String, PackageWrapper>? previous,
    required MapEntry<String, PackageWrapper>? current,
  }) {
    assert(previous != null || current != null,
        'Either previous or current must not be null');
    if (previous == null) {
      return _depAddedOrRemovedStr(
        packageName: current!.key,
        dependencyType: current.value.dependencyType.name,
        changeType: 'ADDED',
      );
    }
    if (current == null) {
      return _depAddedOrRemovedStr(
        packageName: previous.key,
        dependencyType: previous.value.dependencyType.name,
        changeType: 'REMOVED',
      );
    }

    return _depDiffStr(
      packageName: previous.key,
      previousVersion: previous.value.version.toString(),
      currentVersion: current.value.version.toString(),
      dependencyType: current.value.dependencyType.name,
      changelogDiff: _getChangelogDiff(
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

  String _fullOutputStr({
    required String mainApp,
    required String dependencyGroups,
  }) {
    return '''
$mainApp

## Changed Dependencies
$dependencyGroups
''';
  }

  String _groupStr({
    required String groupName,
    required String packagesInGroup,
  }) {
    return _collapsibleStr(
      header: groupName,
      body: packagesInGroup,
    );
  }

  String _emptyDependencyStr() {
    return _paddedDivStr(body: 'No changed dependencies');
  }

  String _mainPackageDiffStr({
    required String packageName,
    required String previousVersion,
    required String currentVersion,
    required String changelogDiff,
  }) {
    return _collapsibleStr(
      header: '$packageName | $previousVersion -> $currentVersion',
      body: changelogDiff,
    );
  }

  String _depDiffStr({
    required String packageName,
    required String previousVersion,
    required String currentVersion,
    required String dependencyType,
    required String changelogDiff,
  }) {
    return _collapsibleStr(
      header:
          '$packageName | $previousVersion -> $currentVersion | $dependencyType',
      body: changelogDiff,
    );
  }

  String _depAddedOrRemovedStr({
    required String packageName,
    required String changeType,
    required String dependencyType,
  }) {
    return '$packageName | $changeType | $dependencyType';
  }

  String _collapsibleStr({
    required String header,
    required String body,
  }) {
    return '''
<details>
  <summary>$header</summary>
  ${_paddedDivStr(body: body)}
</details>
''';
  }

  String _paddedDivStr({required String body}) {
    return '''
  <div style="padding-left: 2em; padding-bottom: 1em">
    $body
  </div>
''';
  }
}
