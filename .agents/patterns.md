# Patterns — copy these recipes

Concrete, repo-accurate templates. Match them exactly; they are what the rest of the code does.

## 1. A model (`data/models/foo.dart`)

Hand-written, immutable, `const` constructor, `copyWith` only if needed. No JSON codegen.

```dart
class Appointment {
  const Appointment({required this.id, required this.doctor, required this.startsAt});

  final String id;
  final String doctor;
  final DateTime startsAt;
}
```

## 2. Repository interface + mock (`data/repositories/`)

```dart
// foo_repository.dart
abstract class FooRepository {
  Future<Result<List<Foo>>> fetchItems();
}

// mock_foo_repository.dart
class MockFooRepository implements FooRepository {
  MockFooRepository(this._config);
  final MockConfig _config;

  @override
  Future<Result<List<Foo>>> fetchItems() async {
    await _config.simulateDelay();                 // realistic loading state
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) return const Result.success([]);
    return const Result.success([/* mock data */]);
  }
}
```

Return `Result<T>` — **never throw** to the UI. Use `AppFailure.network()/.server()/.notFound()`
or `AppFailure(message, retryable: ...)`.

## 3. Providers (`presentation/providers/foo_providers.dart`)

The **only** place that knows the concrete `Mock*` class.

```dart
final fooRepositoryProvider = Provider<FooRepository>((ref) {
  return MockFooRepository(ref.watch(mockConfigProvider));   // <- one line to swap to Api* later
});

final fooItemsProvider = FutureProvider.autoDispose<List<Foo>>((ref) async {
  return (await ref.watch(fooRepositoryProvider).fetchItems()).dataOrThrow;   // Result -> AsyncValue
});
```

- Read-only async data → `FutureProvider.autoDispose`.
- Mutable UI state / multi-step flows (e.g. booking) → `NotifierProvider` + a `*Controller`.
- `.dataOrThrow` turns a `Failure` into `AsyncValue.error` so the UI can render it.

## 4. Screen renders state via `AsyncValueView`

Never hand-roll loading/error/empty branches.

```dart
class FooScreen extends ConsumerWidget {
  const FooScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(fooItemsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Foo')),
      body: AsyncValueView<List<Foo>>(
        value: items,
        isEmpty: (list) => list.isEmpty,
        onRetry: () => ref.invalidate(fooItemsProvider),
        data: (context, list) => ListView(/* ... */),
      ),
    );
  }
}
```

`AsyncValueView` (`core/widgets/states/`) auto-draws skeleton loading, `ErrorStateView`
(with Retry when `AppFailure.retryable`), and empty state. The "not logged in" (permission)
state is handled by the router `redirect`, not per-widget.

## 5. Toggling states for demo/QA

Override `mockConfigProvider` with `forceError` / `forceEmpty` / longer `minDelay` to inspect
every screen's loading/error/empty at once — no backend, no per-file edits.

## Anti-patterns (reject in review)

- ❌ `import '.../mock_foo_repository.dart'` inside a screen/widget.
- ❌ `try/catch` around a repository call in a widget (let `Result` + `AsyncValueView` handle it).
- ❌ Business logic in `data/models/` or `BuildContext` reaching into `data/`.
- ❌ New `build_runner`/`freezed`/`json_serializable` dependency.
- ❌ Hard-coded route string instead of `AppRoutes.*`.
