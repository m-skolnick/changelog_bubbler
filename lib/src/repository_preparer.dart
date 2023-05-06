import 'dart:io';

import 'package:io/io.dart';

/// 1. Copies current repo into temp
/// 2. Checks out ref
/// 3. Returns path of copied repo
Future<void> prepareTempRepo({required String tmpDir}) async {
  // Copy entire repo to temp dir
  await copyPath(Directory.current.path, tmpDir);
}
