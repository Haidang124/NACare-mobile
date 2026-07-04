# AGENTS.md — read this first

Entry point for any human or AI agent writing code in this repo. Keep it short; the
details live in [`.agents/`](.agents/). If you change how the code works, keep these docs in sync.

## What this is

`NAHealth` — a Flutter mobile app for patients of a single hospital. UI-first phase:
all data comes from **mock repositories**; the real HIS/EMR API is wired in later without
touching the UI. The Flutter project lives in [`app/`](app/); product & architecture docs
live in [`docs/`](docs/).

## Golden rules (do not violate)

1. **Feature-first.** New work goes in `app/lib/features/<feature>/`, not in a shared dump. `core/` is only for things used by many features.
2. **Two layers per feature: `data/` and `presentation/`.** Dependency direction is always `presentation → data`. `data/` must never import `presentation/`.
3. **UI talks to repositories only through a Riverpod provider** that returns the **interface** type. Screens/widgets must never import a `*_repository.dart` or `Mock*Repository` directly.
4. **Repositories return `Result<T>`**, never throw raw exceptions at the UI. List/detail screens render state through `AsyncValueView`.
5. **Swapping mock → real API is a one-line change** in the feature's `providers/` file. If your change would force UI edits to swap the data source, it's wrong.
6. **No codegen.** No `build_runner`, `freezed`, or `json_serializable`. Models are hand-written and immutable.
7. **User-facing strings for new code go through ARB** (`app/lib/l10n/app_vi.arb`), not hard-coded in widgets.
8. **Code comments are in English; user-facing strings stay in Vietnamese.** Comments explain *why*, briefly.

## Before you open a PR

Run these from `app/` — all must pass (this is the merge gate, see [definition-of-done](.agents/definition-of-done.md)):

```bash
dart format .
flutter analyze          # must report "No issues found"
flutter test             # includes test/architecture_test.dart (boundary rules)
```

## Where to read next

| You are about to… | Read |
|---|---|
| Name a file/class/provider/route | [.agents/coding-standards.md](.agents/coding-standards.md) |
| Add a feature or decide where a file goes | [.agents/coding-standards.md](.agents/coding-standards.md) + [.agents/architecture.md](.agents/architecture.md) |
| Wire state, data, or error handling | [.agents/patterns.md](.agents/patterns.md) |
| Write a test | [.agents/testing.md](.agents/testing.md) |
| Commit / open / review a PR | [.agents/code-review.md](.agents/code-review.md) |
| Know when a change is "done" | [.agents/definition-of-done.md](.agents/definition-of-done.md) |

Deeper "why" (Vietnamese) is in [docs/architecture/](docs/architecture/).
