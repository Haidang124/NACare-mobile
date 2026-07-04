# Git & code review

## Branches

- Branch off `main`. Never commit directly to `main` or `master`.
- Name: `<type>/<short-desc>` — `feat/lab-results`, `fix/otp-resend-timer`, `chore/ci`,
  `docs/architecture`, `refactor/shared-models`.

## Commits

- One logical change per commit. Keep pure `dart format`/mechanical churn in its **own** commit
  so real diffs stay readable.
- Message: imperative, scoped. This repo also likes user-story references for traceability:
  - `feat: add queue-status screen` or, story-style, `[f] 042 - As a patient, I want to see my queue number`
  - `fix: reset OTP countdown on resend`

## Pull requests

- Fill in the [PR template](../.github/pull_request_template.md). Keep PRs small and focused.
- CI must be green and CODEOWNERS approval obtained before merge (see
  [definition-of-done.md](definition-of-done.md)).

## Reviewer checklist

Approve only when all hold. Most of the top items are also machine-checked by CI — a reviewer
mainly verifies the judgment items.

**Architecture & boundaries**
- [ ] New code lives under the right `features/<x>/` or `core/`; no logic dumped in `core/`.
- [ ] No screen/widget imports a `*_repository.dart`; data access goes through a provider.
- [ ] `data/` doesn't import `presentation/`; no forbidden cross-feature imports.
- [ ] Swapping mock → real API would still be a one-line change (no UI coupling to the mock).

**Patterns**
- [ ] Repositories return `Result<T>`; screens use `AsyncValueView` for list/detail state.
- [ ] No new codegen deps; models are hand-written immutable.
- [ ] Routes use `AppRoutes.*`; new user-facing strings go through ARB.

**Quality**
- [ ] `flutter analyze` clean, `dart format` applied, `flutter test` green (CI proves this).
- [ ] New feature/logic has at least one provider test.
- [ ] Naming matches [coding-standards.md](coding-standards.md).
- [ ] Docs updated if behavior/architecture changed (`docs/`, and these `.agents/` files).

**Judgment (human)**
- [ ] The change actually solves the stated problem; edge cases considered.
- [ ] No secrets, no PII in logs/mock data beyond masked demo values.
- [ ] Complexity is warranted; simpler option was considered.

## For AI agents specifically

- Read [`AGENTS.md`](../AGENTS.md) and the relevant `.agents/` guide before editing.
- Run the three gate commands yourself before declaring done; paste results in the PR.
- Don't invent dependencies or patterns not already used here. If a rule seems to block the
  task, flag it in the PR instead of silently working around a boundary.
