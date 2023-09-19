import 'package:changelog_bubbler/src/dependency_pair.dart';
import 'package:changelog_bubbler/src/dependency_parser.dart';
import 'package:changelog_bubbler/src/dependency_type.dart';
import 'package:collection/collection.dart';

class ChangeManager {
  /// Holds the parsed dependencies for the repo in the current state
  final DependencyParser current;

  /// Holds the parsed dependencies for the repo in the previous state
  final DependencyParser previous;

  /// All of the dependencies that have changed between the previous and current version
  late final List<DependencyPair> changedDeps;

  /// Changed deps grouped by hosted url
  late final Map<String, List<DependencyPair>> groups;

  ChangeManager({
    required this.current,
    required this.previous,
  }) {
    changedDeps = _getChangedDeps();
    groups = _buildGroups();
  }

  List<DependencyPair> _getChangedDeps() {
    final allDeps = {...current.dependencies, ...previous.dependencies};

    final changedDeps = allDeps.values.where((e) =>
        previous.dependencies[e.name]?.sameVersion(e) != true ||
        current.dependencies[e.name]?.sameVersion(e) != true);

    final changedDepNames = changedDeps.map((e) => e.name).toList();
    final sortedChangedDeps = changedDepNames..sort((a, b) => a.compareTo(b));

    return sortedChangedDeps
        .map((e) => DependencyPair(
              current: current.dependencies[e],
              previous: previous.dependencies[e],
            ))
        .toList();
  }

  Map<String, List<DependencyPair>> _buildGroups() {
    final Map<String, List<DependencyPair>> groups = {};

    // Groups are built by section
    // Each section will be for a separate hosted location
    // Gather the unique urls for hosted dependencies
    final urlSet = changedDeps.map((e) => e.trimmedUrl).whereNotNull().toSet();

    // Loop through the groups and locate the pairs of previous and current dep
    // which belong to that group
    for (final groupUrl in urlSet) {
      final depsInGroup = changedDeps.where((e) => e.trimmedUrl == groupUrl);

      // Inside of the group, sort dependencies by dependency type
      for (final dependencyType in DependencyType.sorted) {
        final depsOfDepType =
            depsInGroup.where((e) => e.dependencyType == dependencyType);

        for (final dep in depsOfDepType) {
          groups[groupUrl] = (groups[groupUrl] ?? [])..add(dep);
        }
      }
    }
    return groups;
  }
}
