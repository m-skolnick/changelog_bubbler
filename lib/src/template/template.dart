import 'dart:io';

class Template {
  final String filePath;
  String? _unalteredTemplate;
  String get unalteredTemplate {
    if (_unalteredTemplate != null) {
      return _unalteredTemplate!;
    }
    final templateFile = File(filePath);
    return _unalteredTemplate ??= templateFile.readAsStringSync();
  }

  Template(
    this.filePath, {
    String? templateForTesting,
  }) : _unalteredTemplate = templateForTesting;

  String replaceAll(Map<String, String> replacements) {
    var substitutedTemplate = unalteredTemplate;
    for (final replacement in replacements.entries) {
      substitutedTemplate =
          substitutedTemplate.replaceFirst(replacement.key, replacement.value);
    }
    return substitutedTemplate;
  }
}
