import 'dart:io';
import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/dependency_type.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/package_wrapper.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class DependencyParser {
  late final Map<String, PackageWrapper> dependencies;
  late final Pubspec pubspec;
  final String repoPath;

  final _shell = getDep<BubblerShell>();

  DependencyParser({required this.repoPath}) {
    final pubspecString = File(p.join(repoPath, 'pubspec.yaml')).readAsStringSync();
    pubspec = Pubspec.parse(pubspecString);
  }

  void parseDependencies({
    required bool includeDev,
    required bool includeTransitive,
  }) {
    // Get all of the dependencies from the pubspec.lock
    final lockString = File(p.join(repoPath, 'pubspec.lock')).readAsStringSync();
    final lockfile = PubspecLock.parse(lockString);
    final allDeps = lockfile.packages.map((key, value) => MapEntry(key, PackageWrapper(value)));

    final devDeps = _isolateDevDeps(allDeps.keys);
    var filteredDeps = allDeps;
    if (!includeDev) {
      filteredDeps = _filterDevDeps(filteredDeps, devDeps);
    }
    if (!includeTransitive) {
      filteredDeps = _filterTransitiveDeps(filteredDeps);
    }

    filteredDeps = _labelDependencyTypes(filteredDeps, devDeps);
    dependencies = filteredDeps;
  }

  Map<String, PackageWrapper> _filterDevDeps(Map<String, PackageWrapper> deps, Set<String> devDeps) {
    return {...deps}..removeWhere((key, value) => devDeps.contains(key));
  }

  Map<String, PackageWrapper> _filterTransitiveDeps(Map<String, PackageWrapper> deps) {
    return {...deps}..removeWhere((key, value) => value.package.dependency == 'transitive');
  }

  Map<String, PackageWrapper> _labelDependencyTypes(Map<String, PackageWrapper> deps, Set<String> devDeps) {
    return deps.map((key, value) {
      if (value.package.dependency == 'transitive') {
        if (devDeps.contains(key)) {
          return MapEntry(key, value..dependencyType = DependencyType.transitiveDev);
        }
        return MapEntry(key, value..dependencyType = DependencyType.transitiveMain);
      }
      if (devDeps.contains(key)) {
        return MapEntry(key, value..dependencyType = DependencyType.directDev);
      }
      return MapEntry(key, value..dependencyType = DependencyType.directMain);
    });
  }

  ///  The pubspec.lock does not distinguish "transitive dev" from "transitive main" they are all labeled "transitive"
  ///  So to figure out which transitive dependencies
  ///  came from dev dependencies rather than main dependencies
  ///    we run a `flutter pub deps --no-dev`
  Set<String> _isolateDevDeps(Iterable<String> depNames) {
    // Using runSync because for some reason the process_run was crashing
    // when running this command
    final result = _shell.runSync(
      'dart pub deps --no-dev --style compact',
      workingDir: repoPath,
    );
    final outText = result.outText;
    // Determine which values from the pubspecLock parse
    //  are not also found in the `dart pub deps --no-dev`
    // During the search, add a space around each entry name so that we can be sure
    //  we are actually referring to the entry. We don't want to falsely
    //  match on entry names that are part of a larger name
    // eg: yaml => checked_yaml
    final devDeps = depNames.whereNot((e) => outText.contains(' $e '));
    return devDeps.toSet();
  }
}
