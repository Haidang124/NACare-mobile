# Testing

Two tiers, both under `app/`:

| Tier | Location | Runner | Runs |
|---|---|---|---|
| Unit + widget + **flow** | `test/` | `flutter test` (headless) | every PR in CI |
| **E2E** (on a real device) | `integration_test/` | `flutter test integration_test -d <device>` | locally / nightly |

`test/` runs headless with no device and is the automation gate on every PR. `integration_test/`
drives the same flows through the real engine on an emulator/device for true layout — it is
slower (full app build) so it is **not** on the per-PR path. Shared driver steps live in
[`test/support/flow_steps.dart`](../app/test/support/flow_steps.dart) so both tiers stay in sync.

Mirror the `lib/` path under `test/` (e.g. `test/features/checkin/queue_status_provider_test.dart`);
app-wide flows go in `test/flows/`.

## What to test (priority order)

1. **Provider / controller logic** — the highest-value, easiest target. Override the
   repository provider with a fake and assert the provider's output.
2. **Critical user flows** as headless flow tests in `test/flows/` — e.g.
   `login_flow_test.dart` (onboarding → login → OTP) and `navigation_test.dart` (visits all 5
   tabs, so every top-level screen is built automatically — no manual clicking to catch a
   regression). The same flows run on-device in `integration_test/app_e2e_test.dart`.
3. **Architecture boundaries** — already covered by `test/architecture_test.dart`; extend it
   if you add a new rule.

## Flow / E2E test recipe

Use the shared steps: `pumpApp(tester, {authenticated})` pumps the real app with a zero-delay
mock config (and, for headless runs, a phone-sized surface); `gotoOtpScreen`, `submitValidOtp`,
`visitAllTabs` drive the UI. Notes learned the hard way:

- Give tappable widgets an `AppKeys` key (e.g. bottom-nav tabs, login submit) so finders are
  stable — see `core/keys.dart`.
- `enterText` can't target an **Offstage** field (e.g. `OtpInput`'s hidden TextField). Send text
  to the focused input via `tester.testTextInput.enterText(...)` instead.
- Headless flow tests validate **behavior**, not pixels; `pumpApp` filters cosmetic RenderFlex
  overflows (a font-fallback artifact). Real layout is validated on-device by `integration_test/`.

## Provider test recipe (canonical)

The mock-repository design means no backend and no UI are needed — inject a fake repo and read
the provider through a `ProviderContainer`. Copy
[`test/features/checkin/queue_status_provider_test.dart`](../app/test/features/checkin/queue_status_provider_test.dart).

```dart
class _FakeFooRepository implements FooRepository {
  @override
  Future<Result<List<Foo>>> fetchItems() async => const Result.success([/* fixed data */]);
}

test('fooItemsProvider returns repository data', () async {
  final container = ProviderContainer(
    overrides: [fooRepositoryProvider.overrideWithValue(_FakeFooRepository())],
  );
  addTearDown(container.dispose);

  final result = await container.read(fooItemsProvider.future);
  expect(result, hasLength(/* ... */));
});
```

- Fakes are **deterministic** (no random, no delay) — unlike `Mock*Repository` which adds fake
  latency/errors for demos.
- To exercise loading/error/empty in a widget test, override `mockConfigProvider` instead of
  writing a new fake.

## Widget tests & keys

Find widgets by stable keys from `core/keys.dart` (`AppKeys.*`), not by raw strings or text:

```dart
await tester.tap(find.byKey(AppKeys.loginSubmit));
```

If a widget needs to be reachable in a test, give it an `AppKeys` key rather than an inline
`Key('...')`.

## Rules

- A new feature should ship with at least one provider test.
- Don't hit real network or real time in tests.
- Keep tests fast; prefer `ProviderContainer` unit tests over full `pumpWidget` when logic is
  the thing under test.
