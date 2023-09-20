import 'dart:io';
import 'package:path/path.dart' as p;

class TemplateManager {
  final String filePath;
  final bool isBundledTemplate;
  String? _unalteredTemplate;
  String get unalteredTemplate {
    if (_unalteredTemplate != null) {
      return _unalteredTemplate!;
    }
    var path = '';
    // If the file path is absolute, we assume the user passed in a path override
    if (isBundledTemplate) {
      // If we're using the bundled template, we need to do
      // some file path manipulation to resolve the uri to the asset folder
      // inside the changelog_bubbler package
      final basePackagePath = File(Platform.script.toFilePath()).parent.parent;
      path = p.join(basePackagePath.path, 'template', filePath);
    } else {
      path = filePath;
    }
    final templateFile = File(path);
    return _unalteredTemplate ??= templateFile.readAsStringSync();
  }

  TemplateManager(this.filePath,
      {required this.isBundledTemplate, String? templateForTesting})
      : _unalteredTemplate = templateForTesting;

  String replaceAll(Map<String, String> replacements) {
    var substitutedTemplate = unalteredTemplate;
    for (final replacement in replacements.entries) {
      substitutedTemplate =
          substitutedTemplate.replaceFirst(replacement.key, replacement.value);
    }
    return substitutedTemplate;
  }
}
