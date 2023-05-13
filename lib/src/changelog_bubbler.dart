import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:changelog_bubbler/src/diff_builder.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/repository_preparer.dart';
import 'package:io/io.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

class ChangelogBubbler extends CommandRunner<int> {
  final String workingDir;

  ChangelogBubbler({String? workingDirectory})
      : workingDir = workingDirectory ?? Directory.current.path,
        super('changelog_bubbler', 'Bubbles changelogs from all sub-packages') {
    argParser.addOption(
      'previous-ref',
      help:
          'The previous ref which should be compared with the current ref. If none is passed, this will default to the tag before the current',
    );
    argParser.addOption(
      'output',
      help: 'The output file',
    );
    registerGlobalDependencies();
  }

  @override
  Future<int> run(Iterable<String> args) async {
    final tempDir = Directory.systemTemp.createTempSync('temp_changelog_bubbler_dir');
    try {
      // Parsing the args in the try/catch to see if it throws an exception
      final argResults = parse(args);

      // Ensure the working directory is a dart git repo with no unstaged changes
      await validateWorkingDir();

      // Copy the current repo to the tempDir
      await copyPath(workingDir, tempDir.path);

      // Copies current repo, clear local changes, and check out state to compare
      await RepositoryPreparer(
        repoPath: tempDir.path,
        passedRef: argResults['previous-ref'] as String?,
      ).prepareTempRepo();

      final diff = await DiffBuilder(
        repoPathCurrentState: workingDir,
        repoPathPreviousState: tempDir.path,
      ).buildDiff();

      // write the diff to a file
    } on UsageException catch (e) {
      print(e.message);
      print('');
      print(e.usage);
      return ExitCode.usage.code;
    } catch (e) {
      print('');
      print(e);

      return ExitCode.unavailable.code;
    } finally {
      tempDir.deleteSync(recursive: true);
    }

    return ExitCode.success.code;
  }

  @visibleForTesting
  Future<void> validateWorkingDir() async {
    // Check if current dir is a dart project
    // Error out of it is not a git dir and does not contain a pubspec.yaml
    // We don't want users to accidentally run this in a folder that doesn't contain a flutter project
    final pubspecYamlExists = File(p.join(workingDir, 'pubspec.yaml')).existsSync();
    if (!pubspecYamlExists) {
      throw (Exception('pubspec.yaml not found. Program must be run from a dart repository'));
    }
    final isGitDir = Directory(p.join(workingDir, '.git')).existsSync();
    if (!isGitDir) {
      throw (Exception('.git folder found. Program must be run from a git repository'));
    }
  }
}
