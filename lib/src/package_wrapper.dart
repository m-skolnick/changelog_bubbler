import 'package:changelog_bubbler/src/dependency_type.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/platform_wrapper.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';
import 'package:path/path.dart' as p;

class PackageWrapper {
  final Package package;
  final String name;
  late final DependencyType dependencyType;

  PackageWrapper(this.name, this.package);

  String get version {
    if (package.description is GitPackageDescription) {
      final resolvedRef =
          (package.description as GitPackageDescription).resolvedRef;
      return resolvedRef.substring(0, 7);
    }

    return package.version.toString();
  }

  bool sameVersion(PackageWrapper other) {
    return version == other.version;
  }

// from: dart.cloudsmith.io/alkami/flutter/
//   to: dart.cloudsmith.io%47alkami%47flutter%47
  String getPubCachePath() {
    String path = _systemPubCachePath;
    if (package.description is HostedPackageDescription) {
      final formattedUrl = trimmedUrl?.replaceAll('/', '%47');
      path = p.join(path, 'hosted', formattedUrl, '$name-${package.version}');
    }
    if (package.description is GitPackageDescription) {
      final resolvedRef =
          (package.description as GitPackageDescription).resolvedRef;
      path = p.join(path, 'git', '$name-$resolvedRef');
    }

    return path;
  }

  String? get trimmedUrl {
    final scheme = 'https://';
    final url = _url;
    if (url?.startsWith(scheme) == true) {
      return url?.replaceFirst(scheme, '');
    }
    return url;
  }

  String? get _url {
    if (package.description is HostedPackageDescription) {
      return (package.description as HostedPackageDescription).url;
    }
    if (package.description is GitPackageDescription) {
      return (package.description as GitPackageDescription).url;
    }
    return null;
  }

  String get _systemPubCachePath {
    final platform = getDep<PlatformWrapper>();

    if (platform.isWindows) {
      return '%LOCALAPPDATA%\\Pub\\Cache';
    }

    return '${platform.home}/.pub-cache';
  }
}
