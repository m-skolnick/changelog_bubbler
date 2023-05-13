import 'dart:io';
import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

class DependencyParser {
  late final List<String> hostedUrls;
  late final Map<String, Package> allPackages;

  final _shell = getDep<BubblerShell>();
  final String _repoPath;

  DependencyParser({required String repoPath}) : _repoPath = repoPath;

  Future<void> parseDependencies() async {
    // Get all of the dependencies from the pubspec.lock
    final lockStr = File(p.join(_repoPath, 'pubspec.lock')).readAsStringSync();
    final lockfile = PubspecLock.parse(lockStr);

    // Run a `flutter pub deps --no-dev`
    //  We do this so we can figure out which transitive dependencies
    //  came from main dependencies rather than dev dependencies
    //  The pubspec.lock does not distinguish "transitive dev" from "transitive main"

    // Using runSync because for some reason the process_run was crashing
    // when running this command
    final result = _shell.runSync(
      'dart pub deps --no-dev --style compact',
      workingDir: _repoPath,
    );
    final outText = result.outText;
    // Filter out the entries from the pubspecLock parse
    //  which are not also found in the `dart pub deps`
    // Add a space around each entry name so that we can be sure
    //  we are actually referring to the entry. We don't want to falsely
    //  match on entry names that are part of a larger name
    // eg: yaml => checked_yaml
    final filteredEntries = lockfile.packages.entries.where((e) => outText.contains(' ${e.key} '));
    allPackages = Map.fromEntries(filteredEntries);
  }
}
