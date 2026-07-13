# Coding standards — naming, files, organization

All code is Dart/Flutter. Formatting is enforced by `dart format` (do not hand-format).
Lints are enforced by `analysis_options.yaml` (`flutter analyze` must be clean).

## Naming

| Thing | Convention | Example |
|---|---|---|
| Files & folders | `snake_case` | `appointment_detail_screen.dart` |
| Classes / enums / typedefs | `PascalCase` | `MockCheckinRepository`, `JourneyStepState` |
| Methods / variables / params | `lowerCamelCase` | `getQueueStatus`, `estimatedWaitMinutes` |
| Constants (top-level / static) | `lowerCamelCase`, `k`-prefix only for globals | `kMockValidOtp` |
| Riverpod providers | `lowerCamelCase` ending in `Provider` | `checkinRepositoryProvider`, `queueStatusProvider` |
| Private members | leading `_` | `_config`, `_startCountdown()` |
| Booleans | `is/has/should/can` prefix | `isVerifying`, `shouldFail`, `retryable` |

### File name suffixes (match these exactly)

| Kind | Pattern | Location |
|---|---|---|
| Screen (full page) | `*_screen.dart` → class `*Screen` | `presentation/screens/` |
| Repository interface | `<feature>_repository.dart` → `abstract class <Feature>Repository` | `data/repositories/` |
| Mock repository | `mock_<feature>_repository.dart` → `Mock<Feature>Repository` | `data/repositories/` |
| Providers of a feature | `<feature>_providers.dart` | `presentation/providers/` |
| Controller (Notifier) | `<thing>_controller.dart` → `*Controller` | `presentation/providers/` |
| Model | singular noun `appointment.dart` → class `Appointment` | `data/models/` |
| Reusable feature widget | descriptive `booking_step_date_time.dart` | `presentation/widgets/` |

## Routes

- Every route is a constant on `AppRoutes` (`core/router/app_routes.dart`). **Never** type a
  path string inline.
- Path values are `kebab-case`, nested by ownership: `/profile/payments/:id`.
- For paths with params, add a builder: `AppRoutes.billDetailPath(id)` — don't string-concat.

## Where a new file goes (decision order)

1. **Belongs to exactly one feature?** → `app/lib/features/<feature>/…`
   - Data model / repository → `data/`
   - Screen, widget, provider → `presentation/`
2. **Used by many features (design-system widget, theme token, router, network util)?**
   → `app/lib/core/…`. Do **not** put feature logic in `core/`.
3. **A model needed by several features?** → prefer `core/models/` over cross-importing another
   feature's `data/models/` (see [architecture.md](architecture.md)).

Do not create new top-level folders under `lib/`. The two are `core/` and `features/`.

## Adding a whole new feature

Use the scaffolder — it creates the exact folder/file skeleton so every feature is identical:

```bash
cd app
dart run tool/new_feature.dart lab_results
```

Then register routes in `core/router/` and run `flutter analyze`.

## Formatting & imports

- Run `dart format .` before committing. Trailing commas drive the layout — keep them.
- Import ordering is enforced (`directives_ordering`): `dart:` → `package:` → relative,
  each group alphabetized.
- Prefer relative imports **within** a feature; use `package:nacare_app/...` only in tests.

## Language

- **Code comments (`//` and `///` doc comments) are written in English.** Keep them concise and
  focused on *why*, not *what*.
- **User-facing strings stay in Vietnamese** — this is a Vietnamese hospital app. That includes
  `Text('...')`, `AppFailure` messages, and ARB values. These are product content, not comments.
- Identifiers (types, methods, variables, files) are English, as in the tables above.

## Strings & localization

- New user-facing text → add a key to `app/lib/l10n/app_vi.arb`, run `flutter gen-l10n`,
  read it via `AppLocalizations`. Do not hard-code display strings in widgets.
- Debug/log strings and `Key('...')` identifiers are exempt.
