import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';

Future<void> main(List<String> args) async {
  final pubspecStr = File('pubspec.yaml').readAsStringSync();
  final pubspec = Pubspec.parse(pubspecStr);
  final packageVersion = pubspec.version.toString();

  print(packageVersion);
}
