import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/repository_preparer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:process_run/process_run.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  setUp(() async {
    await registerMockGlobalDependencies();
  });
  test('prepareTempRepo cleans git state of copied repo', () async {
    final shell = getDep<BubblerShell>();

    final sut =
        RepositoryPreparer(repoPath: 'mockDir', passedRef: 'mockPassedRef');
    await sut.prepareTempRepo();
    verify(() => shell.stubbedRun('git clean -dfx', workingDir: 'mockDir'));
    verify(() => shell.stubbedRun('git add --all', workingDir: 'mockDir'));
    verify(() => shell.stubbedRun('git reset --hard', workingDir: 'mockDir'));
  });
  test('prepareTempRepo uses passed ref if not null', () async {
    final shell = getDep<BubblerShell>();

    final sut =
        RepositoryPreparer(repoPath: 'mockDir', passedRef: 'mockPassedRef');
    await sut.prepareTempRepo();
    verify(() =>
        shell.stubbedRun('git checkout mockPassedRef', workingDir: 'mockDir'));
    verifyNever(() => shell.stubbedRun('git describe --tags --abbrev=0 HEAD^'));
  });
  test('prepareTempRepo gets previous tag if passed ref is null', () async {
    final shell = getDep<BubblerShell>();
    final mockResult = MockProcessResult();
    when(() => mockResult.outText).thenReturn('mockTag');
    when(() => shell.stubbedRun(any())).thenAnswer((_) async => mockResult);

    final sut = RepositoryPreparer(repoPath: 'mockDir');
    await sut.prepareTempRepo();
    verify(() => shell.stubbedRun('git describe --tags --abbrev=0 HEAD^'));
    verify(() => shell.stubbedRun('git checkout mockTag'));
  });
  test(
      'prepareTempRepo gets previous commit if passed ref is null and previous tag is empty',
      () async {
    final shell = getDep<BubblerShell>();
    final mockTagResult = MockProcessResult();
    final mockCommitResult = MockProcessResult();
    when(() => mockTagResult.outText).thenReturn('');
    when(() => shell.stubbedRun(any(that: contains('git describe'))))
        .thenAnswer((_) async => mockTagResult);
    when(() => mockCommitResult.outText).thenReturn('mockCommit');
    when(() => shell.stubbedRun(any(that: contains('git rev-parse'))))
        .thenAnswer((_) async => mockCommitResult);

    final sut = RepositoryPreparer(repoPath: 'mockDir');
    await sut.prepareTempRepo();
    verify(() => shell.stubbedRun('git rev-parse --short HEAD^'));
    verify(() => shell.stubbedRun('git checkout mockCommit'));
  });
}
