import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/dependency_parser.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'test_helpers.dart';

void main() {
  setUp(() async {
    await registerMockGlobalDependencies();
    await _prepareTestApp();
  });
  test(
      'includes transitive main dependencies '
      'when includeTransitive', () async {
    final parser = DependencyParser(repoPath: d.sandbox);

    parser.parseDependencies(
      includeDev: true,
      includeTransitive: true,
    );

    expect(parser.dependencies.keys, contains('async'));
  });

  test(
      'includes direct dev dependencies '
      'when includeDev', () async {
    final parser = DependencyParser(repoPath: d.sandbox);

    parser.parseDependencies(
      includeDev: true,
      includeTransitive: true,
    );

    expect(parser.dependencies.keys, contains('mocktail'));
  });
  test(
      'includes transitive dev dependencies '
      'when includeDev and includeTransitive', () async {
    final parser = DependencyParser(repoPath: d.sandbox);

    parser.parseDependencies(
      includeDev: true,
      includeTransitive: true,
    );

    expect(parser.dependencies.keys, contains('matcher'));
  });
  test(
      'excludes direct dev dependencies '
      'when not includeDev', () async {
    final parser = DependencyParser(repoPath: d.sandbox);

    parser.parseDependencies(
      includeDev: false,
      includeTransitive: true,
    );

    expect(
      parser.dependencies.keys.contains('mocktail'),
      isFalse,
    );
  });
  test(
      'excludes transitive dev dependencies '
      'when includeDev and not includeTransitive', () async {
    final parser = DependencyParser(repoPath: d.sandbox);

    parser.parseDependencies(
      includeDev: true,
      includeTransitive: false,
    );

    expect(
      parser.dependencies.keys.contains('matcher'),
      isFalse,
    );
  });
}

Future<void> _prepareTestApp() async {
  final pubYaml = d.file('pubspec.yaml');
  await pubYaml.create();
  pubYaml.io.writeAsStringSync(MockData.mockPubYamlContents);

  final pubLock = d.file('pubspec.lock');
  await pubLock.create();
  pubLock.io.writeAsStringSync(MockData.mockPubLockContents);

  final shell = getDep<BubblerShell>();
  final mockResult = ProcessResultExt.mock(outText: MockData.mockPubDepsOutput);
  when(
    () => shell.stubbedRunSync('dart pub deps --no-dev --style compact'),
  ).thenReturn(mockResult);
}
