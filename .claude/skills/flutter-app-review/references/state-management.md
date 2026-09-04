# State management — Cubit, freezed unions, and the rules `emit` actually has

`docs/mobile.md` §4. `Cubit` over `Bloc` is a deliberate, per-feature decision: Decode has one
trigger, so an event hierarchy with one member would be ceremony. That is not a house rule —
Create's picker has several distinct triggers and is the plausible candidate for `Bloc` when it
is built. A review should not push either direction without naming the triggers.

## Modelling the state

- The union is `sealed`, so the widget's `switch` is exhaustive at compile time. **A `default`
  or `_ =>` branch throws that away** — a fifth state added later then silently renders
  nothing instead of failing the build. **Should fix**, and it defeats the only reason `sealed`
  is there.
- One state per situation, not one class with `isLoading`, `error` and `slip` all nullable.
  The flat version can represent "loading and errored at once", which is not a thing, and every
  widget then re-derives which case it is in. The union is the doc's choice; the flat form is
  defensible when two states genuinely coexist (a loaded list that is also refreshing), so if
  you flag it, flag it as **Consider** with that caveat rather than as a rule.
- State holds what the screen needs to render, not the widgets that render it. A
  `BuildContext`, a `TextEditingController`, or a `Widget` in a state class is a **Blocker** for
  testability — the state can no longer be constructed in a pure-Dart test.
- **A Cubit must not import `package:flutter/material.dart`.** If it navigates, shows a
  `SnackBar`, or reads a `BuildContext`, presentation leaked into logic and the Cubit is no
  longer testable without a widget tree. **Should fix.**

## `emit` — the two rules that bite

**Emitting after `close()` throws.** Any `emit` that follows an `await` can land after the user
popped the page and the framework closed the Cubit. In debug this is a `StateError` in the
middle of an unrelated screen; the fix is a `if (isClosed) return;` before the late emit, or a
Cubit whose lifetime is genuinely the page's. **Should fix** wherever an `await` sits between
the method entry and its final `emit`.

**Emitting an equal state is a no-op.** `bloc` compares with `==`, and freezed generates a deep
`==` for collections. So mutating a list in place and re-emitting the same state object changes
nothing on screen — the widget never rebuilds, and the bug looks like a rendering problem
rather than a state problem. **Blocker** when it happens, because the symptom points away from
the cause. Emit a new state built from new collections.

## Wiring it to the tree

- `BlocProvider(create:)` is lazy; the Cubit is built on first read. A `create:` that both
  constructs and kicks off a load (`..resolve(code)`) is idiomatic and fine — but if nothing
  reads the Cubit on first frame, `lazy: false` is what makes it actually run.
- **Side effects belong in `BlocListener`, not `BlocBuilder`.** A builder can run more than
  once for a state, so navigation or a `SnackBar` in a builder fires twice and the second one
  lands on a disposed route. **Should fix.** `BlocConsumer` when a screen needs both.
- `context.watch` outside `build` throws; `context.read` inside `build` compiles and then
  quietly never rebuilds. Both are usually a `BlocBuilder` that should have been there.
- `buildWhen` and `BlocSelector` are optimisations, not defaults. Reach for them when a
  measurably expensive subtree rebuilds — a slip of at most 20 rows is not that. Premature
  `buildWhen` hides states and the bug it causes looks like a stuck UI.

## What does not belong in the Cubit

Formatting. A Cubit that emits `"18:00"` instead of a `DateTime` has decided the presentation
for every future caller, and its test now asserts on strings. Derivation the server already did
— `totalOdds`, `droppedCount` — does not belong there either; see `models-and-contracts.md`.

## Questions worth asking

- Is every state in the union reachable, and does the widget have a branch for each?
- Which `emit` in this file can run after the page is gone?
- Does any state carry something a pure-Dart test could not construct?
- Would this transition still be verifiable if the repository were a fake?
- Is this a side effect running inside a builder?
