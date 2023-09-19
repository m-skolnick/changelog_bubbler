import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:process_run/shell.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('runSync executes script in working directory', () {
    final shell = BubblerShell.globalConstructor();
    final result = shell.runSync('pwd', workingDir: 'lib');
    expect(result.outText, contains(p.join('changelog_bubbler', 'lib')));
  });
  test('run executes script in working directory', () async {
    final shell = BubblerShell.globalConstructor();
    final result = await shell.run('pwd', workingDir: 'lib');
    expect(result.outText, contains(p.join('changelog_bubbler', 'lib')));
  });
}
