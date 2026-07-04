<!--
Rulebook: /AGENTS.md and /.agents/. Definition of Done: /.agents/definition-of-done.md
Keep PRs small and focused. Put pure `dart format` churn in its own commit.
-->

## What & why

<!-- One or two sentences. Link the issue / user story if any. -->

## How to test

<!-- Steps a reviewer can follow, or the test(s) that cover this. -->

## Definition of Done

Gate (from `app/`, also verified by CI):

- [ ] `dart format .` — no changes
- [ ] `flutter analyze` — No issues found
- [ ] `flutter test` — green (incl. `architecture_test.dart`)

Conventions & correctness:

- [ ] Follows layering & naming (`.agents/architecture.md`, `.agents/coding-standards.md`)
- [ ] No screen/widget imports a repository directly; data goes through a provider
- [ ] Mock → real API stays a one-line swap; new strings via ARB
- [ ] Loading/empty/error handled via `AsyncValueView`; failures are `AppFailure`
- [ ] New feature/logic has at least one provider test
- [ ] Docs (`docs/`, `.agents/`) updated if behavior/architecture changed

## Notes for reviewers

<!-- Trade-offs, anything intentionally out of scope, rules you had to bend (and why). -->
