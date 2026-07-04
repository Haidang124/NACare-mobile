# Definition of Done

A change is "done" — and safe to auto-merge once approved — only when **every** box is checked.
CI enforces the objective ones; the rest are self-attested in the PR.

## Gate (machine-checked by CI)

From `app/`:

- [ ] `dart format .` produces no changes.
- [ ] `flutter analyze` reports **"No issues found"**.
- [ ] `flutter test` passes — including `test/architecture_test.dart` (layer boundaries).

## Correctness

- [ ] The change does what the task/issue asked; primary happy path verified.
- [ ] Loading, empty, and error states exist for any new data screen (via `AsyncValueView`).
- [ ] No raw exceptions surface to the UI; failures are `AppFailure` with a user-readable message.

## Conventions

- [ ] Naming, file placement, and layering follow [coding-standards.md](coding-standards.md)
      and [architecture.md](architecture.md).
- [ ] Mock → real API remains a one-line swap; no UI coupling to `Mock*`.
- [ ] New user-facing strings are in ARB, not hard-coded.

## Tests & docs

- [ ] New feature/logic ships with at least one provider test.
- [ ] If architecture or a documented behavior changed, the relevant `docs/` and `.agents/`
      files are updated in the same PR.

## Housekeeping

- [ ] No stray debug prints (`avoid_print` is on), commented-out code, or unused imports.
- [ ] No secrets/tokens committed; mock data uses masked/demo values only.
- [ ] Pure-formatting changes are isolated in their own commit.

> If any item cannot be met, say so explicitly in the PR description rather than silently
> skipping it — that is how a boundary or a rule gets revisited on purpose.
