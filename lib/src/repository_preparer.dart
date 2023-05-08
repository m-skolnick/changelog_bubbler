import 'package:process_run/process_run.dart';

import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';

class RepositoryPreparer {
  final String repoDir;
  final String? passedRef;

  RepositoryPreparer({
    required this.repoDir,
    this.passedRef,
  });

  /// *. Clear all changes
  /// *. If passed ref is null:
  ///   a. Search for previous tag
  ///   b. If previous tag is null -> Get previous commit
  /// *. Checks out ref
  Future<void> prepareTempRepo() async {
    await _cleanGitState();
    await _checkOutRef();
  }

  Future<void> _cleanGitState() async {
    final shell = getDep<BubblerShell>();

    await shell.run(
      'git clean -dfx',
      workingDir: repoDir,
    );
    await shell.run(
      'git add --all',
      workingDir: repoDir,
    );
    await shell.run(
      'git reset --hard',
      workingDir: repoDir,
    );
  }

  Future<void> _checkOutRef() async {
    final shell = getDep<BubblerShell>();
    final ref = passedRef ?? await _getPreviousTag() ?? await _getPreviousCommit();

    await shell.run(
      'git checkout $ref',
      workingDir: repoDir,
    );
  }

  Future<String?> _getPreviousTag() async {
    final shell = getDep<BubblerShell>();

    try {
      final result = await shell.run(
        'git describe --tags --abbrev=0 HEAD^',
        workingDir: repoDir,
      );
      final outText = result.outText.trim();

      if (outText.isEmpty) {
        return null;
      }

      return outText;
    } catch (e) {
      return null;
    }
  }

  Future<String> _getPreviousCommit() async {
    final shell = getDep<BubblerShell>();

    final result = await shell.run(
      'git rev-parse --short HEAD^',
      workingDir: repoDir,
    );
    final outText = result.outText.trim();

    return outText;
  }
}
