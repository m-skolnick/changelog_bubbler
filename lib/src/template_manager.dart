import 'dart:io';
import 'package:path/path.dart' as p;

class TemplateManager {
  final String filePath;
  String? _unalteredTemplate;
  String get unalteredTemplate {
    if (_unalteredTemplate != null) {
      return _unalteredTemplate!;
    }
    var path = '';
    // If the file path is absolute, we assume the user passed in a path override
    if (p.isAbsolute(filePath)) {
      path = filePath;
    } else {
      // Here we assume the path to the template is the default
      // So we do some manipulation to resolve the uri to the asset folder
      // inside the changelog_bubbler package
      final basePackagePath = File(Platform.script.toFilePath()).parent.parent;
      path = p.join(basePackagePath.path, 'template', filePath);
    }
    final templateFile = File(path);
    return _unalteredTemplate ??= templateFile.readAsStringSync();
  }

  TemplateManager(this.filePath, {String? templateForTesting})
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
