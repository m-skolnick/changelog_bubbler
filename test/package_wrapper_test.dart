import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/package_wrapper.dart';
import 'package:changelog_bubbler/src/platform_wrapper.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

// [START] Mocks

const _mockHash = 'abcd123';
final _mockVersion = Version.parse('0.0.1');

PackageWrapper _mockGitWrapper([Version? version]) {
  return PackageWrapper(
    'mockName',
    Package(
      dependency: 'mockDependency',
      description: GitPackageDescription(
        path: 'mockPath',
        ref: 'mockRef',
        resolvedRef: _mockHash,
        url: 'mockUrl',
      ),
      source: PackageSource.git,
      version: version ?? _mockVersion,
    ),
  );
}

PackageWrapper _mockHostedWrapper({Version? version, String? url}) {
  return PackageWrapper(
    'mockName',
    Package(
      dependency: 'mockDependency',
      description: HostedPackageDescription(
        url: url ?? 'mockUrl',
        name: 'mockName',
      ),
      source: PackageSource.hosted,
      version: version ?? _mockVersion,
    ),
  );
}

// [END] Mocks

void main() {
  test(
      'version resolves to ref '
      'when git package', () {
    final wrapper = _mockGitWrapper();
    expect(wrapper.version, _mockHash);
  });
  test(
      'version resolves to version '
      'when hosted package', () {
    final wrapper = _mockHostedWrapper();
    expect(wrapper.version, _mockVersion.toString());
  });
  test(
      'accurately compares versions '
      'when versions are the same', () {
    final wrapper1 = _mockHostedWrapper(version: Version.parse('0.0.1'));
    final wrapper2 = _mockHostedWrapper(version: Version.parse('0.0.1'));
    expect(wrapper1.sameVersion(wrapper2), isTrue);
  });
  test(
      'accurately compares versions '
      'when versions are different', () {
    final wrapper1 = _mockHostedWrapper(version: Version.parse('0.0.1'));
    final wrapper2 = _mockHostedWrapper(version: Version.parse('0.1.0'));
    expect(wrapper1.sameVersion(wrapper2), isFalse);
  });
  test(
      'accurately builds pub cache path '
      'for git package on Windows', () async {
    await registerMockGlobalDependencies();
    when(() => getDep<PlatformWrapper>().isWindows).thenReturn(true);

    final wrapper = _mockGitWrapper();
    expect(
      wrapper.getPubCachePath(),
      p.join('%LOCALAPPDATA%\\Pub\\Cache', 'git', 'mockName-$_mockHash'),
    );
  });
  test(
      'accurately builds pub cache path '
      'for git package on Mac', () async {
    await registerMockGlobalDependencies();
    final platform = getDep<PlatformWrapper>();
    when(() => platform.isWindows).thenReturn(false);
    when(() => platform.home).thenReturn('mockHome');

    final wrapper = _mockGitWrapper();
    expect(
      wrapper.getPubCachePath(),
      p.join('mockHome/.pub-cache', 'git', 'mockName-$_mockHash'),
    );
  });
  test(
      'accurately builds pub cache path '
      'for hosted package on Windows', () async {
    await registerMockGlobalDependencies();
    final platform = getDep<PlatformWrapper>();
    when(() => platform.isWindows).thenReturn(true);

    final wrapper = _mockHostedWrapper();
    expect(
      wrapper.getPubCachePath(),
      p.join(
        '%LOCALAPPDATA%\\Pub\\Cache',
        'hosted',
        'mockUrl',
        'mockName-$_mockVersion',
      ),
    );
  });
  test(
      'accurately builds pub cache path '
      'for hosted package on Mac', () async {
    await registerMockGlobalDependencies();
    final platform = getDep<PlatformWrapper>();
    when(() => platform.isWindows).thenReturn(false);
    when(() => platform.home).thenReturn('mockHome');

    final wrapper = _mockHostedWrapper();
    expect(
      wrapper.getPubCachePath(),
      p.join(
        'mockHome/.pub-cache',
        'hosted',
        'mockUrl',
        'mockName-$_mockVersion',
      ),
    );
  });
  test(
      'trimmedUrl '
      'cuts https:// from front', () async {
    final wrapper = _mockHostedWrapper(url: 'https://mockUrl');
    expect(wrapper.trimmedUrl, 'mockUrl');
  });
  test(
      'url '
      'parses git url', () async {
    final wrapper = _mockGitWrapper();
    expect(wrapper.url, 'mockUrl');
  });
  test(
      'url '
      'parses hosted url', () async {
    final wrapper = _mockHostedWrapper();
    expect(wrapper.url, 'mockUrl');
  });
}
