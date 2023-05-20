import 'dart:io';

import 'package:pub_api_client/pub_api_client.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

Future<void> main(List<String> args) async {
  final pubspecStr = File('pubspec.yaml').readAsStringSync();
  final pubspec = Pubspec.parse(pubspecStr);
  final packageName = pubspec.name;
  final packageVersion = pubspec.version.toString();

  try {
    await PubClient().packageVersionInfo(packageName, packageVersion);
  } catch (error) {
    print('Success! Version was not found on pub.dev');
    return;
  }
  throw Exception(
      'Error: Version $packageVersion was found on pub.dev. You must bump the package version for a PR to be accepted.');
}
