import 'package:changelog_bubbler/src/change_type.dart';
import 'package:changelog_bubbler/src/dependency_type.dart';
import 'package:changelog_bubbler/src/package_wrapper.dart';

class DependencyPair {
  final PackageWrapper? previous;
  final PackageWrapper? current;

  DependencyPair({
    this.previous,
    this.current,
  }) : assert(previous != null || current != null,
            'Either previous or current must not be null');

  ChangeType get changeType {
    if (previous == null) {
      return ChangeType.added;
    }
    if (current == null) {
      return ChangeType.removed;
    }
    return ChangeType.updated;
  }

  String get name => (previous?.name ?? current?.name)!;
  String? get url => previous?.url ?? current?.url;
  String? get trimmedUrl => previous?.trimmedUrl ?? current?.trimmedUrl;
  DependencyType get dependencyType =>
      (previous?.dependencyType ?? current?.dependencyType)!;

  String? getChangelogDiff() {
    final previousChangelog = previous?.getChangelog();
    final currentChangelog = current?.getChangelog();

    if (previousChangelog == null || currentChangelog == null) {
      return null;
    }

    final diff = currentChangelog.replaceFirst(previousChangelog, '');
    if (diff.isEmpty) {
      return 'Changelog did not contain changes';
    }

    return diff;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dependencyType': dependencyType.name,
      'changeType': changeType.name,
      'url': url,
      'previousVersion': previous?.version,
      'currentVersion': current?.version,
      'changelogDiff': getChangelogDiff(),
    };
  }
}
