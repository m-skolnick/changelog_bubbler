import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/global_dependencies.dart';
import 'package:changelog_bubbler/src/platform_wrapper.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

void main() {
  test('registerGlobalDependencies registers global dependencies', () {
    GetIt.I.reset();
    registerGlobalDependencies();
    expect(GetIt.I.isRegistered<BubblerShell>(), isTrue);
    expect(GetIt.I.isRegistered<PlatformWrapper>(), isTrue);
  });
}
