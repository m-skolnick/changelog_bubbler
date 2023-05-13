import 'package:changelog_bubbler/src/bubbler_shell.dart';
import 'package:changelog_bubbler/src/platform_wrapper.dart';
import 'package:get_it/get_it.dart';

/// A quick accessor for GetIt dependencies
T getDep<T extends Object>() => GetIt.I.get<T>();

/// This global dependency registrar is to make it easy to mock classes
///   and stub methods when testing
/// See [test_helpers.dart] for where global depencies are mocked for tests
void registerGlobalDependencies() {
  if (!GetIt.I.isRegistered<BubblerShell>()) {
    GetIt.I.registerLazySingleton(() => BubblerShell.globalConstructor());
  }
  if (!GetIt.I.isRegistered<PlatformWrapper>()) {
    GetIt.I.registerLazySingleton(() => PlatformWrapper());
  }
}
