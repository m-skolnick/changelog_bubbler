import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/change_manager.dart';
import 'package:changelog_bubbler/src/changelog_builder.dart';
import 'package:changelog_bubbler/src/dependency_parser.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/logger.dart';
import 'package:changelog_bubbler/src/repository_preparer.dart';
import 'package:changelog_bubbler/src/template_manager.dart';
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
    argParser.addOption(
      'changelog-template-path',
      help: 'The path of the root changelog template',
      defaultsTo: 'changelog_template.html',
    );
    argParser.addOption(
      'dependency-group-template-path',
      help: 'The path of the root changelog template',
      defaultsTo: 'dependency_group_template.html',
    );
    argParser.addOption(
      'dependency-changed-template-path',
      help: 'The path of the root changelog template',
      defaultsTo: 'dependency_changed_template.html',
    );
    argParser.addOption(
      'dependency-added-or-removed-template-path',
      help: 'The path of the root changelog template',
      defaultsTo: 'dependency_added_or_removed_template.html',
    );
    argParser.addOption(
      'no-changed-dependencies-template-path',
      help: 'The path of the root changelog template',
      defaultsTo: 'no_changed_dependencies_template.html',
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
    final stopwatch = Stopwatch()..start();
    try {
      final prevousRefArg = argResults['previous-ref'] as String?;
      final changelogName = argResults['changelog-name'] as String;
      final outputArg = argResults['output'] as String;
      final shouldIncludeDevArg = argResults['dev'] as bool;
      final shouldIncludeTransitiveArg = argResults['transitive'] as bool;
      final changelogTemplatePath =
          argResults['changelog-template-path'] as String;
      final dependencyGroupTemplatePath =
          argResults['dependency-group-template-path'] as String;
      final dependencyChangedTemplatePath =
          argResults['dependency-changed-template-path'] as String;
      final dependencyAddedOrRemovedTemplatePath =
          argResults['dependency-added-or-removed-template-path'] as String;
      final noChangedDependenciesTemplate =
          argResults['no-changed-dependencies-template-path'] as String;

      var prompt = 'Ensuring the working directory is a git repo';
      Logger.progressStart(prompt);
      await validateWorkingDir();
      Logger.progressSuccess(prompt);

      prompt = 'Running pub get';
      Logger.progressStart(prompt);
      await runPubGet();
      Logger.progressSuccess(prompt);

      prompt = 'Copying the current repo to a tempDir';
      Logger.progressStart(prompt);
      await copyPath(workingDir, tempDir.path);
      Logger.progressSuccess(prompt);

      await RepositoryPreparer(
        repoPath: tempDir.path,
        passedRef: prevousRefArg,
      ).prepareTempRepo();

      final parserPrevious = DependencyParser(repoPath: tempDir.path);
      final parserCurrent = DependencyParser(repoPath: workingDir);

      prompt = 'Copying the current repo to a tempDir';
      Logger.progressStart(prompt);
      prompt = 'In temp dir: Parsing dependencies from pubspec.lock';
      parserPrevious.parseDependencies(
        includeTransitive: shouldIncludeTransitiveArg,
        includeDev: shouldIncludeDevArg,
      );
      Logger.progressSuccess(prompt);

      prompt = 'In current dir: Parsing dependencies from pubspec.lock';
      Logger.progressStart(prompt);
      parserCurrent.parseDependencies(
        includeTransitive: shouldIncludeTransitiveArg,
        includeDev: shouldIncludeDevArg,
      );
      Logger.progressSuccess(prompt);

      prompt = 'Building diff';
      Logger.progressStart(prompt);
      final diff = await ChangelogBuilder(
        changelogName: changelogName,
        changeManager: ChangeManager(
          previous: parserPrevious,
          current: parserCurrent,
        ),
        changelogTemplate: TemplateManager(
          changelogTemplatePath,
          isBundledTemplate: !argResults.wasParsed('changelog-template-path'),
        ),
        depGroupTemplate: TemplateManager(
          dependencyGroupTemplatePath,
          isBundledTemplate:
              !argResults.wasParsed('dependency-group-template-path'),
        ),
        depChangedTemplate: TemplateManager(
          dependencyChangedTemplatePath,
          isBundledTemplate:
              !argResults.wasParsed('dependency-changed-template-path'),
        ),
        depAddedOrRemovedTemplate: TemplateManager(
          dependencyAddedOrRemovedTemplatePath,
          isBundledTemplate: !argResults
              .wasParsed('dependency-added-or-removed-template-path'),
        ),
        noChangedDependenciesTemplate: TemplateManager(
          noChangedDependenciesTemplate,
          isBundledTemplate:
              !argResults.wasParsed('no-changed-dependencies-template-path'),
        ),
      ).buildChangelogFromTemplates();
      Logger.progressSuccess(prompt);

      prompt = 'Writing diff to file';
      Logger.progressStart(prompt);
      final outputFile = File(outputArg);
      outputFile.writeAsStringSync(diff);
      Logger.progressSuccess(prompt);
      Logger.progressSuccess('Diff written to ${outputFile.absolute}');
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
      final prompt = 'Deleting temp dir';
      Logger.progressStart(prompt);
      tempDir.deleteSync(recursive: true);
      Logger.progressSuccess(prompt);
      print('(${stopwatch.elapsed.inSeconds}s)');
    }

    return ExitCode.success.code;
  }

  /// Ensure the working directory is a git repo
  ///
  /// * Error out of it is not a git dir
  @visibleForTesting
  Future<void> validateWorkingDir() async {
    final isGitDir = Directory(p.join(workingDir, '.git')).existsSync();
    if (!isGitDir) {
      throw (Exception(
          '.git folder not found. Program must be run from a git repository'));
    }
  }

  /// Run a pub get to make sure pubspec.lock exists
  /// This also ensures the working directory is a dart repo
  ///
  /// * We don't want users to accidentally run this in a folder that doesn't contain a dart project
  @visibleForTesting
  Future<void> runPubGet() async {
    final shell = getDep<BubblerShell>();

    try {
      await shell.run(
        'dart pub get',
        workingDir: workingDir,
      );
    } catch (e) {
      throw (Exception(
          '`dart pub get` errored out. Program must be run from the root of a dart project. Error: $e'));
    }
  }
}
