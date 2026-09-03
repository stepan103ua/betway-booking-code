# Models — parity with a contract no compiler enforces

`Slip`, `Selection`, `Fixture`, `Market`, `ConvertResult` and `ApiError` are defined once, in
`docs/backend-api.md` §0. `packages/contracts` is the TypeScript copy of that file and the web
client imports it; **Dart cannot, so `lib/models/` is a hand-maintained mirror** — the only
duplication in this system with nothing checking it. Field-by-field comparison against §0 is
therefore the first thing any model review does, not the last.

- A model field that is not in §0 is a **Blocker**. It came from somewhere — an upstream shape,
  a guess, a UI convenience — and all three are wrong answers.
- A field in §0 that the model omits is a **Should fix** at least: the data arrives and is
  dropped silently, and the gap surfaces as a blank row rather than an error.
- A renamed field is a **Blocker**. The API is already lowerCamelCase, so a `@JsonKey(name:)`
  anywhere in this codebase is a signal that a name drifted — check §0 before accepting it.

## Nullability is contract, not taste

`expiresAt` and `usageCount` are `String | null` and `number | null` in §0, and
`docs/backend-api.md` §1 is explicit that both are **always null from resolve** — upstream's
`FindBookABet` simply does not report them. A non-nullable `String expiresAt` in Dart therefore
does not fail on some rare slip; it fails on the first one, as a type error inside generated
`fromJson` code with a stack trace that points at nothing readable. **Blocker.**

The inverse is worth a look too: a field §0 declares non-nullable but the model makes optional
pushes a null check into every widget that touches it, forever.

## The two Dart JSON traps

**Whole numbers decode as `int`.** `jsonDecode` returns `int` for `2` and `double` for `2.27`,
so `json['odds'] as double` throws the first time a price lands on an exact integer — a real
possibility for `odds`, and near-certain for `totalOdds` on a single-leg slip. `json_serializable`
generates `(json['odds'] as num).toDouble()` and is safe; a hand-written `fromJson` usually is
not. **Blocker**, and the failure is intermittent enough to be blamed on the network.

**`DateTime.parse` of a `Z` timestamp gives a UTC `DateTime`.** `kickoffAt` is ISO-8601 with a
`Z` (§0). Rendering it without `.toLocal()` shows a Lagos user a kickoff an hour early — WAT is
UTC+1 — and nothing throws, which is what makes it a **Blocker** rather than a nuisance. Decide
once whether the model holds `String` or `DateTime` and apply it to every timestamp field; a
model where one is parsed and another is not guarantees one of them is rendered raw.

## Do not recompute what the server computed

`totalOdds` and `droppedCount` arrive in the response. Recomputing either in Dart creates a
second source of truth that disagrees under floating-point rounding, and the client's version
is the one the user sees. **Should fix** — and in this app it is worse than generic, because
§1 specifies that `totalOdds` includes inactive legs. A client that recomputes over active legs
only produces a plausible, wrong number that no test would catch.

`isActive` is the same shape of mistake one layer down: it is already the collapse of Betway's
three staleness flags, decided server-side inside a provider. A client re-deriving staleness
from `kickoffAt.isBefore(now)` is reimplementing a decision it does not own, and it will
disagree the moment a market is suspended on a fixture that has not kicked off.

## Generated code

`.freezed.dart` and `.g.dart` are either committed or gitignored — both are defensible, neither
is automatic. Committed means a reviewer can read the repo without running anything, at the cost
of large diffs on every model change. Ignored means anything that runs `flutter analyze` must
run `build_runner` first, or the analyzer reports hundreds of missing-part errors that look like
a broken checkout. Whichever is chosen, the choice belongs in `apps/mobile/README.md` — an
unstated one is a **Consider** with the CI consequence spelled out.

A `toJson` on a response-only model is dead weight, but harmless; **Nit** at most. What actually
gets sent is small: `{ code }` for resolve and convert, `{ outcomeIds }` for create.

## Questions worth asking

- Does every field here appear in `docs/backend-api.md` §0, with the same name and nullability?
- Which field crashes the parse when a price is exactly `2`?
- Is any timestamp rendered without `.toLocal()`?
- Is the client computing a number the response already contains?
- Can someone clone this repo and run `flutter analyze` without a generation step?
