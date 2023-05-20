import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:changelog_bubbler/src/dependency_parser.dart';
import 'package:changelog_bubbler/src/diff_builder.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/repository_preparer.dart';
import 'package:io/ansi.dart';
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
          'The previous ref which should be compared with the current ref. If none is passed, this will default to the tag before the current. If no tags are found, it will use the previous commit',
    );
    argParser.addOption(
      'output',
      help: 'The output file',
      defaultsTo: 'CHANGELOG_BUBBLED.g.md',
    );
    argParser.addOption(
      'changelog-name',
      help: 'The name of the changelog to search for',
      defaultsTo: 'CHANGELOG.md',
    );
    argParser.addFlag(
      'dev',
      help: 'Include dev dependencies in output',
      defaultsTo: true,
    );
    argParser.addFlag(
      'transitive',
      help: 'Include transitive dependencies in output',
      defaultsTo: true,
    );
    registerGlobalDependencies();
  }

  @override
  Future<int> run(Iterable<String> args) async {
    late final ArgResults argResults;
    try {
      // Parsing the args in the try/catch to see if it throws an exception
      argResults = parse(args);
      if (argResults['help'] as bool) {
        printUsage();
        return ExitCode.success.code;
      }
    } on UsageException catch (e) {
      print(e.message);
      print('');
      print(e.usage);
      return ExitCode.usage.code;
    }
    // Define the tempDir where this repo will be copied to and set to the state to compare
    final tempDir =
        Directory.systemTemp.createTempSync('temp_changelog_bubbler_dir');
    try {
      final prevousRefArg = argResults['previous-ref'] as String?;
      final changelogName = argResults['changelog-name'] as String;
      final outputArg = argResults['output'] as String;
      final shouldIncludeDevArg = argResults['dev'] as bool;
      final shouldIncludeTransitiveArg = argResults['transitive'] as bool;

      print('Ensuring the working directory is a dart git repo...');
      await validateWorkingDir();

      print('Copying the current repo to a tempDir...');
      await copyPath(workingDir, tempDir.path);

      print(
          'In temp dir: Cleaning git state, checking out previous ref, running a pub get...');
      await RepositoryPreparer(
        repoPath: tempDir.path,
        passedRef: prevousRefArg,
      ).prepareTempRepo();

      final parserPrevious = DependencyParser(repoPath: tempDir.path);
      final parserCurrent = DependencyParser(repoPath: workingDir);
      print('In temp dir: Parsing dependencies from pubspec.lock');
      parserPrevious.parseDependencies(
        includeTransitive: shouldIncludeTransitiveArg,
        includeDev: shouldIncludeDevArg,
      );
      print('In current: Parsing dependencies from pubspec.lock...');
      parserCurrent.parseDependencies(
        includeTransitive: shouldIncludeTransitiveArg,
        includeDev: shouldIncludeDevArg,
      );

      print('Building diff...');
      final diff = await DiffBuilder(
        previous: parserPrevious,
        current: parserCurrent,
        changelogName: changelogName,
      ).buildDiff();

      print('Writing diff to file ...');
      final outputFile = File(outputArg);
      outputFile.writeAsStringSync(diff);
      print('${lightGreen.wrap('✓')} Diff written to ${outputFile.absolute}');
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
      print('Deleting temp dir...');
      tempDir.deleteSync(recursive: true);
    }

    return ExitCode.success.code;
  }

  /// Ensure the working directory is a dart git repo
  ///
  /// * Check if current dir is a dart project
  /// * Error out of it is not a git dir and does not contain a pubspec.yaml
  /// * We don't want users to accidentally run this in a folder that doesn't contain a flutter project
  @visibleForTesting
  Future<void> validateWorkingDir() async {
    final pubspecYamlExists =
        File(p.join(workingDir, 'pubspec.yaml')).existsSync();
    if (!pubspecYamlExists) {
      throw (Exception(
          'pubspec.yaml not found. Program must be run from a dart repository'));
    }
    final isGitDir = Directory(p.join(workingDir, '.git')).existsSync();
    if (!isGitDir) {
      throw (Exception(
          '.git folder found. Program must be run from a git repository'));
    }
  }
}
