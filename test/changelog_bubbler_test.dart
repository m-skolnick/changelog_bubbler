import 'dart:io';

import 'package:changelog_bubbler/src/changelog_bubbler.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'test_helpers.dart';

void main() {
  setUp(() async {
    await registerMockGlobalDependencies();
  });
  test('validateWorkingDir ensures directory is a git repo', () async {
    final bubbler = ChangelogBubbler(workingDirectory: d.sandbox);
    await _prepareTestApp();
    Directory(d.path('.git')).deleteSync();

    expect(
        () => bubbler.validateWorkingDir(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: .git folder found. Program must be run from a git repository',
          ),
        ));
  });
  test('validateWorkingDir ensures directory has pubspec.yaml', () async {
    final bubbler = ChangelogBubbler(workingDirectory: d.sandbox);
    await _prepareTestApp();
    File(d.path('pubspec.yaml')).deleteSync();

    expect(
        () => bubbler.validateWorkingDir(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: pubspec.yaml not found. Program must be run from a dart repository',
          ),
        ));
  });
}

Future<void> _prepareTestApp() async {
  await d.dir('.git').create();
  await d.file('pubspec.yaml').create();
}
