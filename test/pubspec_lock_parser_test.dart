import 'package:test/test.dart';

void main() {
  test('empty test', () {
    expect(2 + 2, 4);
  });
}

final pubspecLockSection = '''
  checked_yaml:
    dependency: transitive
    description:
      name: checked_yaml
      sha256: feb6bed21949061731a7a75fc5d2aa727cf160b91af9a3e464c5e3a32e28b5ff
      url: "https://pub.dev"
    source: hosted
    version: "2.0.3"
  cli_readme_builder:
    dependency: "direct main"
    description:
      path: "."
      ref: HEAD
      resolved-ref: a890fc3115588378214962e59e7d67058032a0f1
      url: "https://github.com/m-skolnick/cli_readme_builder.git"
    source: git
    version: "1.6.0"
''';

final mockDependencyMap = '''
{dependency: transitive, description: {name: _fe_analyzer_shared, url: https://pub.dev}, source: hosted, version: 59.0.0}
{dependency: transitive, description: {name: analyzer, url: https://pub.dev}, source: hosted, version: 5.11.1}
{dependency: direct main, description: {name: args, url: https://pub.dev}, source: hosted, version: 2.4.1}
{dependency: transitive, description: {name: async, url: https://pub.dev}, source: hosted, version: 2.11.0}
{dependency: transitive, description: {name: boolean_selector, url: https://pub.dev}, source: hosted, version: 2.1.1}
{dependency: transitive, description: {name: charcode, url: https://pub.dev}, source: hosted, version: 1.3.1}
{dependency: transitive, description: {name: checked_yaml, url: https://pub.dev}, source: hosted, version: 2.0.3}
{dependency: transitive, description: {name: collection, url: https://pub.dev}, source: hosted, version: 1.17.1}
{dependency: direct dev, description: {name: test_descriptor, url: https://pub.dev}, source: hosted, version: 2.0.1}
{dependency: direct dev, description: {name: test_process, url: https://pub.dev}, source: hosted, version: 2.0.3}
''';

final mockPubspecLockJson = '''
packages: {_fe_analyzer_shared: {dependency: transitive, description: {name: _fe_analyzer_shared, url: https://pub.dev}, source: hosted, version: 60.0.0}, analyzer: {dependency: transitive, description: {name: analyzer, url: https://pub.dev}, source: hosted, version: 5.12.0}, args: {dependency: direct main, description: {name: args, url: https://pub.dev}, source: hosted, version: 2.4.1}, async: {dependency: transitive, description: {name: async, url: https://pub.dev}, source: hosted, version: 2.11.0}, boolean_selector: {dependency: transitive, description: {name: boolean_selector, url: https://pub.dev}, source: hosted, version: 2.1.1}, charcode: {dependency: transitive, description: {name: charcode, url: https://pub.dev}, source: hosted, version: 1.3.1}, checked_yaml: {dependency: transitive, description: {name: checked_yaml, url: https://pub.dev}, source: hosted, version: 2.0.3}, collection: {dependency: transitive, description: {name: collection, url: https://pub.dev}, source: hosted, version: 1.17.1}, convert: {dependency: transitive, description: {name: convert, url: https://pub.dev}, source: hosted, version: 3.1.1}, coverage: {dependency: transitive, description: {name: coverage, url: https://pub.dev}, source: hosted, version: 1.6.3}, crypto: {dependency: transitive, description: {name: crypto, url: https://pub.dev}, source: hosted, version: 3.0.3}, file: {dependency: transitive, description: {name: file, url: https://pub.dev}, source: hosted, version: 6.1.4}, fixnum: {dependency: transitive, description: {name: fixnum, url: https://pub.dev}, source: hosted, version: 1.1.0}, frontend_server_client: {dependency: transitive, description: {name: frontend_server_client, url: https://pub.dev}, source: hosted, version: 3.2.0}, get_it: {dependency: direct main, description: {name: get_it, url: https://pub.dev}, source: hosted, version: 7.6.0}, git: {dependency: direct main, description: {name: git, url: https://pub.dev}, source: hosted, version: 2.2.0}, glob: {dependency: transitive, description: {name: glob, url: https://pub.dev}, source: hosted, version: 2.1.1}, http_multi_server: {dependency: transitive, description: {name: http_multi_server, url: https://pub.dev}, source: hosted, version: 3.2.1}, http_parser: {dependency: transitive, description: {name: http_parser, url: https://pub.dev}, source: hosted, version: 4.0.2}, io: {dependency: direct main, description: {name: io, url: https://pub.dev}, source: hosted, version: 1.0.4}, js: {dependency: transitive, description: {name: js, url: https://pub.dev}, source: hosted, version: 0.6.7}, json_annotation: {dependency: transitive, description: {name: json_annotation, url: https://pub.dev}, source: hosted, version: 4.8.1}, lints: {dependency: direct dev, description: {name: lints, url: https://pub.dev}, source: hosted, version: 2.0.1}, logger: {dependency: direct main, description: {name: logger, url: https://pub.dev}, source: hosted, version: 1.3.0}, logging: {dependency: transitive, description: {name: logging, url: https://pub.dev}, source: hosted, version: 1.1.1}, matcher: {dependency: transitive, description: {name: matcher, url: https://pub.dev}, source: hosted, version: 0.12.15}, meta: {dependency: direct main, description: {name: meta, url: https://pub.dev}, source: hosted, version: 1.9.1}, mime: {dependency: transitive, description: {name: mime, url: https://pub.dev}, source: hosted, version: 1.0.4}, mocktail: {dependency: direct dev, description: {name: mocktail, url: https://pub.dev}, source: hosted, version: 0.3.0}, node_preamble: {dependency: transitive, description: {name: node_preamble, url: https://pub.dev}, source: hosted, version: 2.0.2}, package_config: {dependency: transitive, description: {name: package_config, url: https://pub.dev}, source: hosted, version: 2.1.0}, path: {dependency: direct main, description: {name: path, url: https://pub.dev}, source: hosted, version: 1.8.3}, pool: {dependency: transitive, description: {name: pool, url: https://pub.dev}, source: hosted, version: 1.5.1}, process_run: {dependency: direct main, description: {name: process_run, url: https://pub.dev}, source: hosted, version: 0.13.0}, protobuf: {dependency: transitive, description: {name: protobuf, url: https://pub.dev}, source: hosted, version: 2.1.0}, pub_semver: {dependency: direct main, description: {name: pub_semver, url: https://pub.dev}, source: hosted, version: 2.1.4}, pubspec_lock_parse: {dependency: direct main, description: {name: pubspec_lock_parse, url: https://pub.dev}, source: hosted, version: 2.2.0}, shelf: {dependency: transitive, description: {name: shelf, url: https://pub.dev}, source: hosted, version: 1.4.1}, shelf_packages_handler: {dependency: transitive, description: {name: shelf_packages_handler, url: https://pub.dev}, source: hosted, version: 3.0.2}, shelf_static: {dependency: transitive, description: {name: shelf_static, url: https://pub.dev}, source: hosted, version: 1.1.2}, shelf_web_socket: {dependency: transitive, description: {name: shelf_web_socket, url: https://pub.dev}, source: hosted, version: 1.0.4}, source_map_stack_trace: {dependency: transitive, description: {name: source_map_stack_trace, url: https://pub.dev}, source: hosted, version: 2.1.1}, source_maps: {dependency: transitive, description: {name: source_maps, url: https://pub.dev}, source: hosted, version: 0.10.12}, source_span: {dependency: transitive, description: {name: source_span, url: https://pub.dev}, source: hosted, version: 1.10.0}, stack_trace: {dependency: transitive, description: {name: stack_trace, url: https://pub.dev}, source: hosted, version: 1.11.0}, stream_channel: {dependency: transitive, description: {name: stream_channel, url: https://pub.dev}, source: hosted, version: 2.1.1}, string_scanner: {dependency: transitive, description: {name: string_scanner, url: https://pub.dev}, source: hosted, version: 1.2.0}, synchronized: {dependency: transitive, description: {name: synchronized, url: https://pub.dev}, source: hosted, version: 3.1.0}, term_glyph: {dependency: transitive, description: {name: term_glyph, url: https://pub.dev}, source: hosted, version: 1.2.1}, test: {dependency: direct dev, description: {name: test, url: https://pub.dev}, source: hosted, version: 1.24.2}, test_api: {dependency: transitive, description: {name: test_api, url: https://pub.dev}, source: hosted, version: 0.5.2}, test_core: {dependency: transitive, description: {name: test_core, url: https://pub.dev}, source: hosted, version: 0.5.2}, test_descriptor: {dependency: direct dev, description: {name: test_descriptor, url: https://pub.dev}, source: hosted, version: 2.0.1}, test_process: {dependency: direct dev, description: {name: test_process, url: https://pub.dev}, source: hosted, version: 2.0.3}, typed_data: {dependency: transitive, description: {name: typed_data, url: https://pub.dev}, source: hosted, version: 1.3.2}, vm_service: {dependency: transitive, description: {name: vm_service, url: https://pub.dev}, source: hosted, version: 11.7.0}, watcher: {dependency: transitive, description: {name: watcher, url: https://pub.dev}, source: hosted, version: 1.0.2}, web_socket_channel: {dependency: transitive, description: {name: web_socket_channel, url: https://pub.dev}, source: hosted, version: 2.4.0}, webkit_inspection_protocol: {dependency: transitive, description: {name: webkit_inspection_protocol, url: https://pub.dev}, source: hosted, version: 1.2.0}, yaml: {dependency: transitive, description: {name: yaml, url: https://pub.dev}, source: hosted, version: 3.1.2}}, sdks: {dart: >=2.19.0 <3.0.0}}
''';

// dart pub deps --style list --no-dev
final mockPubDepsOutput = '''
Dart SDK 2.19.2
Flutter SDK 3.7.3
changelog_bubbler 0.1.0

dependencies:
- args 2.4.1
- get_it 7.6.0
  - async ^2.6.0
  - collection ^1.15.0
- git 2.2.0
  - path ^1.0.0
- io 1.0.4
  - meta ^1.3.0
  - path ^1.8.0
  - string_scanner ^1.1.0
- logger 1.3.0
- meta 1.9.1
- path 1.8.3
- process_run 0.13.0
  - path >=1.8.0 <3.0.0
  - collection >=1.15.0 <3.0.0
  - charcode >=1.2.0 <3.0.0
  - string_scanner >=1.1.0 <3.0.0
  - yaml >=3.0.0 <5.0.0
  - meta >=1.3.0 <3.0.0
  - args >=2.0.0 <4.0.0
  - pub_semver >=2.0.0 <4.0.0
  - synchronized >=3.0.0 <5.0.0
- pub_semver 2.1.4
  - collection ^1.15.0
  - meta ^1.3.0
- pubspec_lock_parse 2.2.0
  - args ^2.3.1
  - json_annotation ^4.6.0
  - pub_semver ^2.1.1
  - checked_yaml ^2.0.1

transitive dependencies:
- async 2.11.0
  - collection ^1.15.0
  - meta ^1.1.7
- charcode 1.3.1
- checked_yaml 2.0.3
  - json_annotation ^4.3.0
  - source_span ^1.8.0
  - yaml ^3.0.0
- collection 1.17.1
- json_annotation 4.8.1
  - meta ^1.4.0
- source_span 1.10.0
  - collection ^1.15.0
  - path ^1.8.0
  - term_glyph ^1.2.0
- string_scanner 1.2.0
  - source_span ^1.8.0
- synchronized 3.1.0
- term_glyph 1.2.1
- yaml 3.1.2
  - collection ^1.15.0
  - source_span ^1.8.0
  - string_scanner ^1.1.0
''';

/*
> dart pub deps --no-dev --style compact 
Dart SDK 2.19.2
Flutter SDK 3.7.3
changelog_bubbler 0.1.0

dependencies:
- args 2.4.1
- get_it 7.6.0 [async collection]
- git 2.2.0 [path]
- io 1.0.4 [meta path string_scanner]
- logger 1.3.0
- meta 1.9.1
- path 1.8.3
- process_run 0.13.0 [path collection charcode string_scanner yaml meta args pub_semver synchronized]
- pub_semver 2.1.4 [collection meta]
- pubspec_lock_parse 2.2.0 [args json_annotation pub_semver checked_yaml]

transitive dependencies:
- async 2.11.0 [collection meta]
- charcode 1.3.1
- checked_yaml 2.0.3 [json_annotation source_span yaml]
- collection 1.17.1
- json_annotation 4.8.1 [meta]
- source_span 1.10.0 [collection path term_glyph]
- string_scanner 1.2.0 [source_span]
- synchronized 3.1.0
- term_glyph 1.2.1
- yaml 3.1.2 [collection source_span string_scanner]
*/