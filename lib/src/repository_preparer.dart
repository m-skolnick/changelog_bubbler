import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

/// 1. Creates a temp directory
/// 1. Copies current repo into temp
/// 1. Checks out ref
Future<String> prepareTempRepoAtRef({required String ref}) async {
  GetIt.I.get<Logger>().i('test message');
  final tempDir = Directory('temp_changelog_bubbler_dir')..createSync();
  // await copyPath(Directory.current.path, tempDir.path);

  return tempDir.path;
}
