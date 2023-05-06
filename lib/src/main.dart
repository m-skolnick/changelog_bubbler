import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:changelog_bubbler/src/package_comparer.dart';
import 'package:changelog_bubbler/src/pub_lock_parser.dart';
import 'package:changelog_bubbler/src/repository_preparer.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(
      'ref',
      abbr: 'r',
      help:
          'Reference to compare with current. If none is passed, this will default to the tag before the currently checked out state',
    );

  final results = parser.parse(arguments);

  final ref = results['ref'] as String?;

  if (ref == null) {
    print('A reference to compare with current is required.');
    exit(1);
  }

  // TODO: Implement the changelog diff functionality.
}

class ChangelogBubbler extends CommandRunner<int> {
  ChangelogBubbler() : super('changelog_bubbler', 'Bubbles changelogs from all sub-packages') {
    argParser.addOption(
      'previous-ref',
      help:
          'The previous ref which should be compared with the current ref. If none is passed, this will default to the tag before the current',
    );
    argParser.addOption(
      'previous-ref',
      help:
          'The previous ref which should be compared with the current ref. If none is passed, this will default to the tag before the current',
    );
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);

      return await buildBubbledChangelog(argResults);
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
    }
  }

  Future<int> buildBubbledChangelog(ArgResults topLevelResults) async {
    final tempDir = Directory('temp_changelog_bubbler_dir')..createSync();
    // final tempDir = Directory.systemTemp.createTempSync('changelog_diff');

    try {
      _validateCurrentDir();
      await prepareTempRepo(tmpDir: tempDir.path);
      final previousDependencyList = await getDependencyList(repoPath: tempDir.path);
      final currentDependencyList = await getDependencyList(repoPath: Directory.current.path);
      final diff = buildDiff(
        previous: previousDependencyList,
        current: currentDependencyList,
      );
    } catch (e) {
      print('Failed with Error: $e');
    }

    // Clean up the temporary directory.
    tempDir.deleteSync(recursive: true);
    return ExitCode.success.code;
  }

  void _validateCurrentDir() {
    // Check if current dir is a dart project
    // Error out of it is not a git dir and does not contain a pubspec.yaml
    // We don't want users to accidentally run this in a folder that doesn't contain a flutter project
    final currentDir = Directory.current.path;

    final pubspecYamlExists = File(p.join(currentDir, 'pubspec.yaml')).existsSync();
    if (!pubspecYamlExists) {
      throw (Exception('pubspec.yaml not found. Program must be run from a dart repository'));
    }
    final isGitDir = Directory(p.join(currentDir, '.git')).existsSync();
    if (!isGitDir) {
      throw (Exception('.git folder found. Program must be run from a git repository'));
    }
  }
}
