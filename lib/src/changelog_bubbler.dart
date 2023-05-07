import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/package_comparer.dart';
import 'package:changelog_bubbler/src/pubspec_lock_parser.dart';
import 'package:changelog_bubbler/src/repository_preparer.dart';
import 'package:io/io.dart';
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
    final tmpDir = Directory.systemTemp.createTempSync('temp_changelog_bubbler_dir');
    try {
      // Try parsing the args just to see if it throws an exception
      parse(args);

      // Ensure the working directory is a dart git repo with no unstaged changes
      await validateWorkingDir();

      // Copy the current repo to the tempDir
      await copyPath(workingDir, tmpDir.path);

      // Check out
      await prepareTempRepo(repoDir: tmpDir.path);

      final previousDependencyList = await getDependencyList(repoPath: tmpDir.path);
      final currentDependencyList = await getDependencyList(repoPath: workingDir);
      final diff = buildDiff(
        previous: previousDependencyList,
        current: currentDependencyList,
      );
    } on UsageException catch (e) {
      print(e.message);
      print('');
      print(e.usage);
      return ExitCode.usage.code;
    } catch (e) {
      print('Unknown Exception');
      print('');
      print(e);

      return ExitCode.unavailable.code;
    } finally {
      tmpDir.deleteSync(recursive: true);
    }

    return ExitCode.success.code;
  }

  Future<void> validateWorkingDir() async {
    final shell = getDep<BubblerShell>();

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

    print('Checking to make sure git status is clean');
    await shell.run(
      'git diff --exit-code',
      workingDir: workingDir,
    );
  }
}
