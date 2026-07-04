# `.agents/` — the coding rulebook

Machine- and human-readable rules for writing code in this repo. Written in English and
kept short so an AI agent can load them and start producing correct, review-ready code
without re-deriving conventions each time.

Start from the root [`AGENTS.md`](../AGENTS.md), then dive into the relevant guide below.

## Contents

| File | Answers |
|---|---|
| [coding-standards.md](coding-standards.md) | How do I name files/classes/providers/routes? Where does a new file go? |
| [architecture.md](architecture.md) | What are the layers and boundaries? What may import what? |
| [patterns.md](patterns.md) | How do I add a provider, repository, model, and render state? |
| [testing.md](testing.md) | What do I test and how? |
| [code-review.md](code-review.md) | Branch/commit conventions and the review checklist. |
| [definition-of-done.md](definition-of-done.md) | The gate a change must pass before merge. |

## How "auto-approve" actually works

A markdown file cannot approve a PR by itself. Fast/automatic approval is the *result* of a
green, self-checking pipeline plus a clear checklist — set it up like this:

1. **Definition of Done** ([definition-of-done.md](definition-of-done.md)) — an objective
   checklist. If every box is checked, the change is mergeable.
2. **CI enforces the objective parts** — `.github/workflows/ci.yml` runs `dart format`,
   `flutter analyze`, and `flutter test` (incl. `architecture_test.dart`, which fails the
   build on any layer-boundary violation). No human needed to catch these.
3. **`CODEOWNERS` auto-requests the right reviewer**, and the
   [PR template](../.github/pull_request_template.md) puts the checklist in every PR.
4. **Recommended GitHub setup** (repo admin): branch protection on `main` requiring the CI
   check + one CODEOWNERS approval, with **auto-merge** enabled. Then a PR that is green and
   approved merges itself — the "auto-approve" you want, without lowering the bar.

The guides here exist so that AI-generated PRs pass steps 1–2 on the first try.
