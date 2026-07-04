// Architecture test — blocks layer-boundary violations by scanning imports in lib/.
//
// Builds no UI and runs no app: it only reads source and checks the rules in
// docs/architecture/05-quy-tac-va-dong-gop.md. If someone imports across a boundary,
// `flutter test` (and CI) go red — no need to catch it by eye in review.
//
// The "shared feature" rule (auth, patient_profiles... imported by other features) is a
// human decision, not checked here — see doc 05, the shared-features section.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  String norm(String path) => path.replaceAll('\\', '/');

  final importRe = RegExp('''import\\s+['"]([^'"]+)['"]''');
  List<String> importsOf(File f) => f
      .readAsLinesSync()
      .expand((line) => importRe.allMatches(line).map((m) => m.group(1)!))
      .toList();

  test('data/ never imports back up into presentation/', () {
    final offenders = <String>[];
    for (final f in dartFiles) {
      final path = norm(f.path);
      if (!path.contains('/data/')) continue;
      for (final imp in importsOf(f)) {
        if (imp.contains('presentation/')) offenders.add('$path  ->  $imp');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'The data layer must be independent of the UI (dependency direction is '
          'always presentation -> data):\n${offenders.join('\n')}',
    );
  });

  test(
      'screens/ and widgets/ do not import data/repositories/ directly '
      '(must go through a provider)', () {
    final offenders = <String>[];
    for (final f in dartFiles) {
      final path = norm(f.path);
      final isView = path.contains('/presentation/screens/') ||
          path.contains('/presentation/widgets/');
      if (!isView) continue;
      for (final imp in importsOf(f)) {
        if (imp.contains('data/repositories/')) {
          offenders.add('$path  ->  $imp');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Screens/widgets must obtain the repository through a provider, not by '
          'importing the repository/mock class directly:\n${offenders.join('\n')}',
    );
  });
}
