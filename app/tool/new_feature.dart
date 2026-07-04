// Generates the skeleton of a new feature following the feature-first 2-layer layout.
//
// Usage:   dart run tool/new_feature.dart <feature_name_snake_case>
// Example: dart run tool/new_feature.dart lab_results
//
// Creates: data/{models,repositories} + presentation/{providers,screens,widgets}
// with an interface repository, a mock repository and a sample provider — so every
// feature shares the same skeleton and newcomers don't have to memorize the layout.
// Never overwrites an existing file.

import 'dart:io';

void main(List<String> args) {
  if (args.length != 1 || !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(args.single)) {
    stderr.writeln('Expected exactly one feature name in snake_case.');
    stderr.writeln('Example: dart run tool/new_feature.dart lab_results');
    exit(64);
  }

  final name = args.single; // e.g. lab_results
  final pascal = name
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(); // e.g. LabResults
  final root = 'lib/features/$name';

  if (Directory(root).existsSync()) {
    stderr.writeln('Feature "$name" already exists at $root — aborting.');
    exit(1);
  }

  final files = <String, String>{
    '$root/data/models/${name}_item.dart': '''
/// Plain immutable model for the $name feature (hand-written). No BuildContext / UI logic.
class ${pascal}Item {
  const ${pascal}Item({required this.id, required this.title});

  final String id;
  final String title;
}
''',
    '$root/data/repositories/${name}_repository.dart': '''
import '../models/${name}_item.dart';
import '../../../../core/network/result.dart';

/// Interface — the UI/providers depend only on this, never on the mock or the API.
abstract class ${pascal}Repository {
  Future<Result<List<${pascal}Item>>> fetchItems();
}
''',
    '$root/data/repositories/mock_${name}_repository.dart': '''
import '../models/${name}_item.dart';
import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '${name}_repository.dart';

class Mock${pascal}Repository implements ${pascal}Repository {
  Mock${pascal}Repository(this._config);

  final MockConfig _config;

  @override
  Future<Result<List<${pascal}Item>>> fetchItems() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) return const Result.success([]);
    return const Result.success([
      ${pascal}Item(id: '1', title: 'Mẫu 1'),
      ${pascal}Item(id: '2', title: 'Mẫu 2'),
    ]);
  }
}
''',
    '$root/presentation/providers/${name}_providers.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../data/models/${name}_item.dart';
import '../../data/repositories/${name}_repository.dart';
import '../../data/repositories/mock_${name}_repository.dart';

/// The ONLY place that knows the concrete Mock class — swap this single line to
/// Api${pascal}Repository when the real API is ready.
final ${_camel(name)}RepositoryProvider = Provider<${pascal}Repository>((ref) {
  return Mock${pascal}Repository(ref.watch(mockConfigProvider));
});

final ${_camel(name)}ItemsProvider =
    FutureProvider.autoDispose<List<${pascal}Item>>((ref) async {
  return (await ref.watch(${_camel(name)}RepositoryProvider).fetchItems()).dataOrThrow;
});
''',
    '$root/presentation/screens/${name}_screen.dart': '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../providers/${name}_providers.dart';

class ${pascal}Screen extends ConsumerWidget {
  const ${pascal}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(${_camel(name)}ItemsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      // AsyncValueView renders loading/error/empty per the 5-state checklist.
      body: AsyncValueView<List<${pascal}Item>>(
        value: items,
        onRetry: () => ref.invalidate(${_camel(name)}ItemsProvider),
        isEmpty: (list) => list.isEmpty,
        data: (context, list) => ListView(
          children: [for (final it in list) ListTile(title: Text(it.title))],
        ),
      ),
    );
  }
}
''',
    '$root/presentation/widgets/.gitkeep': '',
  };

  for (final entry in files.entries) {
    final file = File(entry.key);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value.trimLeft());
    stdout.writeln('  created  ${entry.key}');
  }

  stdout.writeln('\nDone: feature "$name".');
  stdout.writeln('Remaining (manual):');
  stdout.writeln(
      '  - Register routes in core/router/app_routes.dart + app_router.dart');
  stdout.writeln(
      '  - Check AsyncValueView `data`/`onRetry` params match the real signature');
  stdout.writeln('  - flutter analyze');
}

String _camel(String snake) {
  final parts = snake.split('_');
  return parts.first +
      parts
          .skip(1)
          .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
          .join();
}
