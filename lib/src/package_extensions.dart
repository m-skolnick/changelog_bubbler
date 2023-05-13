import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/platform_wrapper.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';
import 'package:path/path.dart' as p;

extension PackageExtension on Package {
  String? get trimmedUrl {
    final scheme = 'https://';
    final url = _getUrl();
    if (url?.startsWith(scheme) == true) {
      return url?.replaceFirst(scheme, '');
    }
    return url;
  }

  // Passing in the name because the
  // GitPackageDescription doesn't have a name in it
  String getPubCachePath({required String name}) {
    String path = _systemPubCachePath;
    if (description is HostedPackageDescription) {
      path = p.join(path, 'hosted', trimmedUrl, '$name-$version');
    }
    if (this is GitPackageDescription) {
      final resolvedRef = (this as GitPackageDescription).resolvedRef;
      path = p.join(path, 'git', '$name-$resolvedRef');
    }

    return path;
  }

  String? _getUrl() {
    if (description is HostedPackageDescription) {
      return (description as HostedPackageDescription).url;
    }
    if (description is GitPackageDescription) {
      return (description as GitPackageDescription).url;
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
