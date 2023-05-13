import 'package:changelog_bubbler/src/dependency_parser.dart';

class DiffBuilder {
  final String repoPathCurrentState;
  final String repoPathPreviousState;

  /// Holds the parsed dependencies for the repo in the current state
  late final DependencyParser parserCurrent;

  /// Holds the parsed dependencies for the repo in the previous state
  late final DependencyParser parserPrevious;

  DiffBuilder({
    required this.repoPathCurrentState,
    required this.repoPathPreviousState,
  });

  Future<String> buildDiff() async {
    parserPrevious = DependencyParser(repoPath: repoPathPreviousState);
    await parserPrevious.parseDependencies();
    parserCurrent = DependencyParser(repoPath: repoPathCurrentState);
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
