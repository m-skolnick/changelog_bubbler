import 'package:changelog_bubbler/src/changelog_bubbler.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  test('validateWorkingDir ensures directory is a git repo', () async {
    final bubbler = ChangelogBubbler(workingDirectory: d.sandbox);
    await d.file('pubspec.yaml').create();
    expect(
        () => bubbler.validateWorkingDir(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: .git folder found. Program must be run from a git repository',
          ),
        ));
  });
}
