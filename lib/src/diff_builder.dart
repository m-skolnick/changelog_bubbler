import 'package:changelog_bubbler/src/dependency_parser.dart';

class DiffBuilder {
  final String repoInCurrentState;
  final String repoInPreviousState;

  DiffBuilder({
    required this.repoInCurrentState,
    required this.repoInPreviousState,
  });

  Future<List<String>> buildDiff() async {
    final previousDependencies = await DependencyParser(repoPath: repoInCurrentState).getDependencies();
    final currentDependencies = await DependencyParser(repoPath: repoInPreviousState).getDependencies();
    return [];
  }
}
