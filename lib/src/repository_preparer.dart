import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:process_run/process_run.dart';

/// 1. If passed ref is null:
///   a. Search for previous tag
///   b. If previous tag is null -> Get previous commit
/// 2. Checks out ref
Future<void> prepareTempRepo({required String repoDir, String? passedRef}) async {
  final ref = passedRef ?? await _getPreviousTag(repoDir: repoDir) ?? await _getPreviousCommit(repoDir: repoDir);
  final shell = getDep<BubblerShell>();

  await shell.run(
    'git checkout $ref',
    workingDir: repoDir,
  );
}

Future<String?> _getPreviousTag({required String repoDir}) async {
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

Future<String> _getPreviousCommit({required String repoDir}) async {
  final shell = getDep<BubblerShell>();

  final result = await shell.run(
    'git rev-parse --short HEAD^',
    workingDir: repoDir,
  );
  final outText = result.outText.trim();

  return outText;
}
