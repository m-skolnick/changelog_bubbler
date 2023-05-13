import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

extension PackageDescriptionExtension on PackageDescription {
  String? getUrl() {
    if (this is HostedPackageDescription) {
      return (this as HostedPackageDescription).url;
    }
    if (this is GitPackageDescription) {
      return (this as GitPackageDescription).url;
    }
    return null;
  }

  String getPubCachePath() {
    const macLinuxPubCachePath = '\$HOME/.pub-cache';
    const windowsPubCachePath = '%LOCALAPPDATA%\\Pub\\Cache';
    return '';
  }
}
