import 'package:changelog_bubbler/src/dependency_pair.dart';
import 'package:changelog_bubbler/src/dependency_type.dart';
import 'package:changelog_bubbler/src/package_wrapper.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

// [START] Mocks

final _mockVersion = Version.parse('0.0.1');

class _MockPackageWrapper extends Mock implements PackageWrapper {}

PackageWrapper _mockPackageWrapper({Version? version, String? changelog}) {
  final mockPackageWrapper = _MockPackageWrapper();
  when(() => mockPackageWrapper.url).thenReturn('mockUrl');
  when(() => mockPackageWrapper.name).thenReturn('mockName');
  when(() => mockPackageWrapper.version)
      .thenReturn(version?.toString() ?? _mockVersion.toString());
  when(() => mockPackageWrapper.dependencyType).thenReturn(
    DependencyType.directMain,
  );
  when(() => mockPackageWrapper.getChangelog()).thenReturn(
    changelog ?? 'mockChangelog',
  );

  return mockPackageWrapper;
}

// [END] Mocks

void main() {
  test(
      'toJson()'
      'accurately builds when changeType==UPDATED', () {
    final pair = DependencyPair(
      previous: _mockPackageWrapper(
        version: Version.parse('1.0.0'),
        changelog: '''
previous changelog
''',
      ),
      current: _mockPackageWrapper(
        version: Version.parse('2.0.0'),
        changelog: '''
current changelog
previous changelog
''',
      ),
    );

    final result = pair.toJson();
    expect(result, {
      'name': 'mockName',
      'dependencyType': 'direct main',
      'changeType': 'UPDATED',
      'url': 'mockUrl',
      'previousVersion': '1.0.0',
      'currentVersion': '2.0.0',
      'changelogDiff': '''
current changelog
''',
    });
  });
  test(
      'toJson()'
      'accurately builds when changeType==ADDED', () {
    final pair = DependencyPair(
      current: _mockPackageWrapper(version: Version.parse('2.0.0')),
    );

    final result = pair.toJson();
    expect(result, {
      'name': 'mockName',
      'dependencyType': 'direct main',
      'changeType': 'ADDED',
      'url': 'mockUrl',
      'previousVersion': null,
      'currentVersion': '2.0.0',
      'changelogDiff': null,
    });
  });
  test(
      'toJson()'
      'accurately builds when changeType==REMOVED', () {
    final pair = DependencyPair(
      previous: _mockPackageWrapper(version: Version.parse('1.0.0')),
    );

    final result = pair.toJson();
    expect(result, {
      'name': 'mockName',
      'dependencyType': 'direct main',
      'changeType': 'REMOVED',
      'url': 'mockUrl',
      'previousVersion': '1.0.0',
      'currentVersion': null,
      'changelogDiff': null,
    });
  });
}
