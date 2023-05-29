import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/dependency_parser.dart';
import 'package:changelog_bubbler/src/diff_builder.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/package_wrapper.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'test_helpers.dart';

void main() {
  setUp(() async {
    await registerMockGlobalDependencies();
    await _prepareTestApp();
  });
  test('creates new section for each host', () async {
    final previousParser = DependencyParser(repoPath: d.sandbox)
      ..dependencies = _previousDependencyMap;
    final currentParser = DependencyParser(repoPath: d.sandbox)
      ..dependencies = _currentDependencyMap;

    final diffBuilder = DiffBuilder(
      previous: previousParser,
      current: currentParser,
      changelogName: 'changelogName',
    );
    expect(await diffBuilder.buildDiff(), contains('async'));
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

final _previousDependencyMap = {
  'hosted': PackageWrapper(
    'hosted_dep',
    Package(
      dependency: 'direct main',
      description: HostedPackageDescription(name: 'name', url: 'hosted_url'),
      source: PackageSource.hosted,
      version: Version.parse('1.0.0'),
    ),
  ),
  'git_dep': PackageWrapper(
    'git_dep',
    Package(
      dependency: 'direct main',
      description: GitPackageDescription(
          path: 'path', ref: 'ref', resolvedRef: 'resolvedRef', url: 'git_url'),
      source: PackageSource.git,
      version: Version.parse('1.0.0'),
    ),
  ),
};
final _currentDependencyMap = {
  'hosted_dep': PackageWrapper(
    'hosted_dep',
    Package(
      dependency: 'direct main',
      description: HostedPackageDescription(name: 'name', url: 'hosted_url'),
      source: PackageSource.hosted,
      version: Version.parse('2.0.0'),
    ),
  ),
  'pub_dev_dep': PackageWrapper(
    'pub_dev_dep',
    Package(
      dependency: 'direct dev',
      description: HostedPackageDescription(name: 'name', url: 'pub_dev_url'),
      source: PackageSource.hosted,
      version: Version.parse('2.0.0'),
    ),
  ),
};
