import 'dart:io';

import 'package:process_run/process_run.dart';

class BubblerShell {
  BubblerShell.globalConstructor();

  Future<ProcessResult> run(
    String script, {
    required String workingDir,
  }) async {
    final resultList = await Shell(workingDirectory: workingDir).run(script);
    return resultList.first;
  }
}
