import 'dart:io';
import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

class DependencyParser {
  late final Map<String, Package> dependencies;
  final String repoPath;

  final _shell = getDep<BubblerShell>();

  DependencyParser({required this.repoPath});

  void parseDependencies({
    required bool includeDev,
    required bool includeTransitive,
  }) {
    // Get all of the dependencies from the pubspec.lock
    final lockStr = File(p.join(repoPath, 'pubspec.lock')).readAsStringSync();
    final lockfile = PubspecLock.parse(lockStr);
    Map<String, Package> filteredDeps = lockfile.packages;

    if (!includeDev) {
      filteredDeps = _filterDevDeps(filteredDeps);
    }
    if (!includeTransitive) {
      filteredDeps = _filterTransitiveDeps(filteredDeps);
    }
    dependencies = filteredDeps;
  }

  ///  The pubspec.lock does not distinguish "transitive dev" from "transitive main"
  ///  So to figure out which transitive dependencies
  ///  came from dev dependencies rather than main dependencies
  ///    we run a `flutter pub deps --no-dev`
  Map<String, Package> _filterDevDeps(Map<String, Package> deps) {
    // Using runSync because for some reason the process_run was crashing
    // when running this command
    final result = _shell.runSync(
      'dart pub deps --no-dev --style compact',
      workingDir: repoPath,
    );
    final outText = result.outText;
    // Filter out the entries from the pubspecLock parse
    //  which are not also found in the `dart pub deps`
    // Add a space around each entry name so that we can be sure
    //  we are actually referring to the entry. We don't want to falsely
    //  match on entry names that are part of a larger name
    // eg: yaml => checked_yaml
    final filteredEntries = deps.entries.where((e) => outText.contains(' ${e.key} '));
    return Map.fromEntries(filteredEntries);
  }

  Map<String, Package> _filterTransitiveDeps(Map<String, Package> deps) {
    return deps..removeWhere((key, value) => value.dependency == 'transitive');
  }
}
