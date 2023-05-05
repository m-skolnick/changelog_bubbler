import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:changelog_bubbler/src/repository_preparer.dart';
import 'package:io/io.dart';

class ChangelogBubbler extends CommandRunner<int> {
  ChangelogBubbler() : super('changelog_bubbler', 'Bubbles changelogs from all sub-packages') {
    argParser.addOption(
      'previous-ref',
      help:
          'The previous ref which should be compared with the current ref. If none is passed, this will default to the tag before the current',
    );
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);

      return await buildChangelog(argResults);
    } on UsageException catch (e) {
      print(e.message);
      print('');
      print(e.usage);
      return ExitCode.usage.code;
    } catch (e) {
      print('Unknown Exception');
      print('');
      print(e.toString());

      return ExitCode.unavailable.code;
    }
  }

  Future<int> buildChangelog(ArgResults topLevelResults) async {
    await prepareTempRepoAtRef(ref: 'main');
    return ExitCode.success.code;
  }
}
