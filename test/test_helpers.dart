import 'dart:io';

import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockProcessResult extends Mock implements ProcessResult {}

class _MockBubblerShell extends Mock implements BubblerShell {}

Future<void> registerMockGlobalDependencies() async {
  await GetIt.I.reset();

  _stubShell();
}

void _stubShell() {
  final mockShell = _MockBubblerShell();
  final mockResult = MockProcessResult();
  when(() => mockShell.run(
        any(),
        workingDir: any(named: 'workingDir'),
      )).thenAnswer((_) async => mockResult);

  GetIt.I.registerLazySingleton<BubblerShell>(() => mockShell);
}

extension TestHelper on BubblerShell {
  Future<ProcessResult> stubbedRun(
    String script, {
    String? workingDir,
  }) =>
      run(
        script,
        workingDir: workingDir ?? any(named: 'workingDir'),
      );
}
