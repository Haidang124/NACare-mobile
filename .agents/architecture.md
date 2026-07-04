# Architecture & boundaries

Model: **feature-first + a 2-layer repository pattern, with Riverpod for DI/state**
(MVVM-ish: a provider/controller is the view-model). Full rationale (Vietnamese) is in
[docs/architecture/00-tong-quan-kien-truc.md](../docs/architecture/00-tong-quan-kien-truc.md).

## The two layers

```
features/<feature>/
├── data/
│   ├── models/          # plain immutable data, hand-written. No BuildContext, no navigation.
│   └── repositories/    # <feature>_repository.dart (interface) + mock_<feature>_repository.dart
└── presentation/
    ├── providers/       # Riverpod providers/controllers = the "view-model". Builds the Mock repo.
    ├── screens/         # full-page widgets, read providers only
    └── widgets/         # feature-local widgets
```

## Import rules (enforced by `test/architecture_test.dart`)

| Rule | Enforced? |
|---|---|
| `data/` must not import `presentation/` | ✅ test fails build |
| `screens/` & `widgets/` must not import `data/repositories/` (go through a provider) | ✅ test fails build |
| `providers/` is the **only** place that constructs a `Mock*Repository` | convention |
| `data/models/` holds no UI/logic (`BuildContext`, routing) | convention |

If you need a repository in the UI, expose it via a provider and `ref.watch` it. Never
`import '.../mock_x_repository.dart'` from a screen or widget.

## Cross-feature dependencies

Some features are **shared infrastructure** and may be imported by others:

- `auth` — session / login state
- `patient_profiles` — the currently-selected patient profile (read by many screens)
- `notifications` — badge / unread count

Outside that set, avoid importing another feature. Rules:

- You may import another feature's **model** or a **shared feature's provider**.
- You may **never** import another feature's `Mock*Repository`.
- If two+ features need the same model, move it to `core/models/` instead of cross-importing
  (e.g. `checkin` currently borrows `queue_status` from `appointments` — that's the kind of
  coupling to migrate).

## `core/` — what belongs here

`theme/` (AppColors, AppTypography, AppSpacing), `router/` (AppRoutes + GoRouter),
`network/` (`Result`, `AppFailure`, `MockConfig`, `error_mapper`), `widgets/` (design system,
incl. `AsyncValueView`), `keys.dart`, `utils/`. Nothing feature-specific.

## Wiring the real API later

Each feature swaps mock → real in **one line** in its `providers/` file:

```dart
// from
return MockCheckinRepository(ref.watch(mockConfigProvider));
// to
return ApiCheckinRepository(ref.watch(httpClientProvider));
```

Map HTTP/network errors to `AppFailure` in one place via `core/network/error_mapper.dart`
(ideally inside the client interceptor). No widget changes.
