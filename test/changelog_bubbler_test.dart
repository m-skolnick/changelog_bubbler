import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/changelog_bubbler.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'test_helpers.dart';

void main() {
  setUp(() async {
    await registerMockGlobalDependencies();
  });
  test('validateWorkingDir throws if not a git repo', () async {
    final bubbler = ChangelogBubbler(workingDirectory: d.sandbox);
    await _prepareTestApp(withGit: false);

    await expectLater(
        bubbler.validateWorkingDir(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: .git folder not found. Program must be run from a git repository',
          ),
        ));
  });
  test('validateWorkingDir does not throw if git folder is found', () async {
    final bubbler = ChangelogBubbler(workingDirectory: d.sandbox);
    await _prepareTestApp(withGit: true);

    await expectLater(bubbler.validateWorkingDir(), completes);
  });
  test('runPubGet executes a pub get', () async {
    final bubbler = ChangelogBubbler(workingDirectory: d.sandbox);
    final shell = getDep<BubblerShell>();

    await _prepareTestApp(withGit: false);
    await bubbler.runPubGet();
    verify(
        () => shell.run('dart pub get', workingDir: any(named: 'workingDir')));
  });
  test('runPubGet throws if pub get fails', () async {
    final bubbler = ChangelogBubbler(workingDirectory: d.sandbox);
    final shell = getDep<BubblerShell>();

    await _prepareTestApp(withGit: false);
    when(() => shell.stubbedRun('dart pub get'))
        .thenThrow(Exception('mock error'));

    await expectLater(
        bubbler.runPubGet(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: `dart pub get` errored out. Program must be run from the root of a dart project. Error: Exception: mock error',
          ),
        ));
  });
}

Future<void> _prepareTestApp({required bool withGit}) async {
  if (withGit) {
    await d.dir('.git').create();
  }
  final shell = getDep<BubblerShell>();
  final mockResult = MockProcessResult();
  when(() => shell.stubbedRun('dart pub get'))
      .thenAnswer((_) async => mockResult);
}
