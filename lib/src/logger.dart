import 'dart:io';

import 'package:io/ansi.dart';

class Logger {
  static final _greenCheck = '${lightGreen.wrap('✓')}';

  static void progressStart(String prompt) {
    stdout.write('$prompt...');
  }

  static void progressSuccess(String prompt) {
    stdout.write('\r$_greenCheck $prompt   \n');
  }
}
