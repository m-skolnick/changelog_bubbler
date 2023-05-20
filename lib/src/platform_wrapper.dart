// coverage:ignore-file

import 'dart:io';

class PlatformWrapper {
  bool get isWindows {
    return Platform.isWindows;
  }

  String get home {
    if (Platform.isWindows) {
      return Platform.environment['UserProfile']!;
    }
    return Platform.environment['HOME']!;
  }
}
