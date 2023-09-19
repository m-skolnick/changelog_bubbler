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
  String? get trimmedUrl => previous?.trimmedUrl ?? current?.trimmedUrl;
  DependencyType get dependencyType =>
      (previous?.dependencyType ?? current?.dependencyType)!;
}
