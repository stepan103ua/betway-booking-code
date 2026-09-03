---
name: flutter-app-review
description: Review Flutter / Dart client code in this repository — feature-first layout, the repository interface seam, get_it composition, Cubit state modelling with freezed, dio and the DioException → Failure mapping, model parity with the documented API contract, widget rebuild scope and state branches, bloc_test/mocktail coverage, and build and release setup. Use whenever the user asks for a review, critique, second opinion, or "would this pass a code review" on the Flutter app — and proactively whenever they show you a cubit, state, page, widget, repository, data source, model, or test file from apps/mobile, even if they only said "here's what I wrote" or "does this look ok". Also use it when asked about flutter_bloc, get_it, freezed or dio conventions, the mobile project structure, or whether a screen matches its documented contract.
---

# Flutter app review

Reviews client code in `apps/mobile` against the design documents in `docs/`, which are the
source of truth for this product. Three of them matter here: `docs/mobile.md` fixes the
structure, `docs/backend-api.md` §0 fixes the shapes that cross the wire, and
`docs/frontend.md` shows what the other client does with the same data. A review that
contradicts a doc without saying so is worse than no review — the doc may be wrong, but that
is itself the finding.

The reader writes Flutter professionally, so skip the fundamentals entirely — no explaining
widgets, `async`, or null safety. What is newer is `flutter_bloc` specifically: the production
background is GetX, and `flutter_bloc` was chosen here deliberately (`docs/mobile.md` §12). Be
concrete about Bloc-family idiom, about Dart-specific parsing traps, and about where this app's
layering deliberately mirrors the backend's — that parallel is the fastest way to explain a
finding to this reader.

## Review workflow

1. **Establish the diff.** Review the change, not the repository. Ask what changed if it is
   not obvious — a review that wanders into unrelated files loses the thread.
2. **Check the contract first.** For any model or data source, open `docs/backend-api.md` §0
   and compare field by field: names, types, nullability. Dart cannot import
   `packages/contracts`, so `lib/models/` is a hand-maintained mirror with no compiler holding
   it in place. A field that has drifted outranks every style finding below it.
3. **Read for intent before style.** What is this screen trying to show, and does it? A slip
   that renders the wrong odds beats every naming opinion in the file.
4. **Walk the relevant checklists.** Load only the reference files the diff actually touches.
5. **Rank by severity and cut ruthlessly.** Five real findings beat twenty. A review with
   twenty items gets skimmed and ignored.
6. **Name what is good, specifically.** Not encouragement — calibration. Someone who cannot
   tell which of their instincts were right cannot build on them.

## Reference files

Load only what the diff touches:

- `references/architecture.md` — feature boundaries, the four layers, the repository seam, `get_it` and the composition root
- `references/state-management.md` — Cubit choice, freezed unions, emit rules, what belongs in state
- `references/data-layer.md` — one `Dio`, timeouts, base URL on a real device, `DioException` → `Failure`
- `references/models-and-contracts.md` — parity with `docs/backend-api.md` §0, nullability, the Dart JSON traps
- `references/ui.md` — state branches, rebuild scope, what the slip card must not hide
- `references/testing.md` — `bloc_test` and `mocktail`, layer isolation, what deserves a test
- `references/tooling-and-release.md` — analyze and format, `--dart-define`, signing, the APK

Each file ends with the questions worth asking of that area. Use those rather than
pattern-matching against a rule list.

## Severity levels

Label every finding. The labels exist so the reader knows what to fix tonight and what to note
in a backlog.

- **Blocker** — a crash, a wrong number shown to a user, a leaked secret, a response field
  silently dropped. Would block a merge.
- **Should fix** — a real bug or maintenance trap, but not dangerous today. Fix before moving on.
- **Consider** — a better idiom or an approach worth knowing. Genuinely optional.
- **Nit** — style or naming. Cap at two per review; beyond that they are noise. If
  `flutter analyze` already reports it, it is not a review finding at all.

## Output format

```
## Review: <what changed>

**Verdict:** <one or two sentences — is this mergeable, and what is the single most important thing to fix>

### Blockers
- **<file:line>** — <what is wrong>. <what the user sees when it goes wrong>. <what to do about it>

### Should fix
- ...

### Consider
- ...

### Worth keeping
- <specific thing they got right, and why it is right>
```

Skip empty sections rather than writing "None". A review with no blockers should look
confident about that, not apologetic.

## Calibration

**Anchor every finding to a consequence, not to authority.** "`jsonDecode` gives you `int` for
a whole-number price, so the first slip with odds of exactly 2.0 crashes the parse" teaches
something. "This violates best practice" teaches nothing and invites cargo-culting.

**Anchor it to the device, specifically.** This app runs on a phone on a Nigerian mobile
connection — the same audience that shaped the backend's caching. A missing timeout is a
spinner with no end; an unbounded rebuild is a dropped frame someone can feel. Server-side
instincts about what is "cheap" do not transfer unexamined.

**Be honest about the strength of an opinion.** Some findings are objectively wrong code;
others are one defensible choice among several. Say which is which. A reviewer who presents
taste as law makes the reader worse at judging trade-offs alone.

**Fixes are welcome, reasoning is mandatory.** Suggesting corrected code is fine here — but
never as a bare diff. The reader has to be able to reconstruct and defend the decision without
you, so lead with why, then show the code.

**Do not re-report the analyzer.** `flutter_lints` already flags missing `const`, unawaited
futures, and `BuildContext` across an async gap. Repeating a lint spends the reader's attention
on something their editor already underlined. Review what the analyzer cannot see.

**Watch for Clean Architecture cosplay.** A domain `Entity` that is a field-for-field copy of
`Slip`, a `UseCase` class per repository method, `Either` from `fpdart`, a `BaseCubit` with one
subclass. `docs/mobile.md` §3 and §12 already declined the first and third by name — so
proposing them is not just over-engineering, it is a silent disagreement with a doc. Flag it as
**Consider** and say which section it contradicts.

**Watch harder for what is missing.** An absent state branch, an absent timeout, an absent
`dispose`, an absent test for the failure path, an absent `.toLocal()` on a kickoff time —
none of these appear in a diff, and they are exactly what separates a screen that demos from a
screen that ships. Scan for them deliberately; they will not announce themselves.
