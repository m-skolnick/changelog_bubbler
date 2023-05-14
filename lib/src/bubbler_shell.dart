import 'dart:io';

import 'package:io/io.dart';
import 'package:process_run/shell.dart';

class BubblerShell {
  BubblerShell.globalConstructor();

  ProcessResult runSync(
    String script, {
    required String workingDir,
  }) {
    final parts = shellSplit(script);
    final executable = parts[0];
    final arguments = parts.sublist(1);
    final result = Process.runSync(
      executable,
      arguments,
      includeParentEnvironment: true,
      runInShell: true,
      workingDirectory: workingDir,
    );

    return result;
  }

  Future<ProcessResult> run(
    String script, {
    required String workingDir,
  }) async {
    final resultList = await Shell(
      workingDirectory: workingDir,
      commandVerbose: false,
      commentVerbose: false,
      verbose: false,
      throwOnError: false,
      runInShell: true,
    ).run(script);

    return resultList.first;
  }
}
