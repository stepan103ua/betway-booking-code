# UI — what the widget layer must show, and what it must not decide

`docs/mobile.md` §10. The slip card renders the same information the web client's does; the
field list is `docs/backend-api.md` §0, and `docs/frontend.md` §6 has the reasoning about
which failures deserve an error surface and which do not.

## Every state gets a branch that says something

The `switch` over the sealed state is exhaustive by construction. What the compiler cannot
check is whether each branch is useful.

- A branch returning `SizedBox.shrink()` for an error state is a silent failure: the user taps
  Decode, nothing happens, and there is nothing on screen to explain it. **Should fix.**
- Loading, error and empty are three different screens, not one spinner with edge cases. An
  empty state is where `GET /api/booking-codes/popular` belongs — that endpoint exists to give
  the Decode screen something to show before anyone has typed.
- `invalid_code` is a `404` and an ordinary outcome of this product, not an exception.
  `docs/frontend.md` §6 makes the same call for the web client: it renders as UI state, not as
  an error boundary. A full-screen crash face for a mistyped code is disproportionate and reads
  as a broken app.

## What the slip card must not hide

**Filtering out `isActive == false` deletes the product.** The whole point of decoding a code
here is seeing what has gone stale before you reuse it — a `where((s) => s.isActive)` in the
widget is a **Blocker** in this app specifically, even though it would be unremarkable
elsewhere. Inactive legs render, visibly distinct, and still count toward the displayed
`totalOdds` because §1 says the total includes them.

Odds drift between encode and decode is expected (`CLAUDE.md`, upstream traps). The UI surfaces
what the API returned; it does not reconcile, round away, or apologise for a difference.

## Rebuild scope and cost

- `build()` runs often. Filtering selections, computing a total, or constructing a
  `DateFormat` inside it does that work on every frame that touches this subtree. Derivation
  belongs in the Cubit, formatting in a pure function or extension outside `build`.
- **Do not repeat the analyzer.** `prefer_const_constructors` and
  `use_build_context_synchronously` are in `flutter_lints` and already underlined in the
  editor. Flag a missing `const` only when it is inside a builder that runs per row.
- `ListView.builder` is for lists that do not fit in memory or on screen. A slip is capped at
  20 legs by the API's own bound, so a `Column` inside a `SingleChildScrollView` is the right
  size of tool — flagging its absence is a cargo-culted finding, and worth resisting.
- `MediaQuery.of(context)` subscribes the widget to every `MediaQuery` change, so showing the
  keyboard rebuilds a widget that only wanted the width. `MediaQuery.sizeOf(context)` scopes it.
  **Consider**, and it is the kind of thing that only shows up as jank on a cheap device.

## Layout and text

- A long `eventName` — `"Mamelodi Sundowns vs. Milford FC"` is a real one — inside a `Row`
  without `Expanded` or `Flexible` overflows with the yellow-and-black stripes. That is a
  **Should fix** and it will not appear in whatever fixture the screen was built against.
- Text scaling is a system setting, not an edge case. Fixed-height containers around text clip
  at large scale factors.
- Hardcoded colours and paddings are fine until they repeat. One screen does not need a design
  system; the third copy of the same inactive-row grey does. Proportionate — **Nit** on first
  sight, **Consider** once it has spread.

## Lifecycle

`TextEditingController`, `ScrollController`, `AnimationController` and `FocusNode` are disposed
in `dispose()`. A missing one is a leak that a review catches and a demo never does — **Should
fix**. Anything held by a `StatelessWidget` that needs disposing is the wrong widget type.

## Questions worth asking

- What is on screen for each state in the union — and does each one tell the user what to do?
- Is any selection being filtered out of the list before it is rendered?
- What runs inside `build()` that does not depend on the frame?
- What happens to this row at the longest event name and the largest text scale?
- Is every controller in this file disposed?
