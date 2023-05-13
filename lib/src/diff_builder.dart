import 'package:changelog_bubbler/src/dependency_parser.dart';

class DiffBuilder {
  /// Holds the parsed dependencies for the repo in the current state
  final DependencyParser parserCurrent;

  /// Holds the parsed dependencies for the repo in the previous state
  final DependencyParser parserPrevious;

  DiffBuilder({
    required this.parserPrevious,
    required this.parserCurrent,
  });

  Future<String> buildDiff() async {
    await parserPrevious.parseDependencies();
    await parserCurrent.parseDependencies();

    // final changedDeps = parserPrevious.allPackages.entries.where((e){
    //   // parserCurrent.
    // });

    return '';
  }

  String getFullOutput() {
    var output = _fullOutputTemplate;

    output = output.replaceFirst(
      '{{app_name}}',
      'TODO - add app name', // TODO add app name
    )
      ..replaceFirst(
        '{{app_changelog}}',
        'TODO app changelog', // TODO add app changelog
      )
      ..replaceFirst(
        '{{diff_by_section}}',
        _getSectionOutputs(),
      );

    return output;
  }

  String _getSectionOutputs() {
    final output = _sectionTemplate;
    return '';
  }

  static const _fullOutputTemplate = '''
# Bubbled Changelog

{{app_name}}

{{app_changelog}}

{{diff_by_section}}
''';

  static const _sectionTemplate = '''
## {{section_name}}

{{package_diffs}}
''';

  static const _packageDiffTemplate = '''
{{package_name}} {{previous_version}} - {{new_version}}

{{changelog_diff}}
''';
}
