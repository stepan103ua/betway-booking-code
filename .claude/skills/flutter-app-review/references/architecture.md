# Architecture — feature-first, and the seams that make it worth paying for

The structure is fixed in `docs/mobile.md` §2–§3. The value of it is not tidiness; it is that
adding a second screen costs roughly what the first one cost, and that each layer can be
tested without the ones below it.

## Layer boundaries

| Layer | Owns | Must never |
|---|---|---|
| `features/*/data/datasources/` | the `dio` call, the endpoint path, raw JSON in and out | know about `Failure`, a Cubit, or a widget |
| `features/*/data/repositories/` | calling the data source, `DioException` → `Failure` | import `flutter/material.dart`, hold state |
| `features/*/domain/repositories/` | the abstract contract the Cubit depends on | import anything from `data/` or `presentation/` |
| `features/*/presentation/cubit/` | state, calling the interface, catching `Failure` | import `dio`, the `Impl`, or `material.dart` |
| `features/*/presentation/pages+widgets/` | rendering a state, dispatching intent | contain logic, call a repository directly |
| `core/` | the `Dio` instance, `get_it` wiring, `Failure` | contain anything specific to one feature |
| `models/` | shapes more than one feature would use | live inside any one feature |

Three tests catch most violations.

**Could you delete `dio` from `pubspec.yaml` and still compile `presentation/`?** If a Cubit or
a widget imports `dio` or catches a `DioException`, transport leaked upward past the layer whose
only real job was to stop it — **Should fix**, and the Cubit's test now needs a mocked HTTP
client to exist.

**Could `features/create/` be added without importing anything from `features/decode/`?** A
cross-feature import is the exact coupling feature-first exists to prevent — **Blocker**. The
fix is never a re-export; it is moving the shared thing up to `models/` or `core/`, which is
why `Slip` lives there already (§2).

**Could the whole `presentation/` layer be deleted and the rest still make sense?** If the
repository returns something shaped for a widget, or a data source formats a date for display,
UI concerns have leaked downward.

## The repository seam

`BookingCodeRepository` (the abstract class in `domain/`) is the mobile counterpart of
`BookingCodeProvider` server-side, and it earns its keep the same way: the Cubit is written
against an interface, so `bloc_test` never needs `dio` anywhere near it (§8).

- A Cubit whose constructor takes `BookingCodeRepositoryImpl` rather than the interface is a
  **Blocker** — it is the one thing this layout exists to prevent, and it silently makes the
  test suite depend on a networking library.
- An import of `BookingCodeRepositoryImpl` anywhere but `core/di.dart` is the same finding
  wearing a different hat.
- New repository method → add it to the interface first, then the implementation. An interface
  trailing its implementation has stopped being a contract.

Resist adding a second abstraction beside it. A `UseCase` class wrapping one repository call,
or a generic `ApiClient` with a single caller, is indirection with no swap behind it.

## Composition root

`core/di.dart` plus `main.dart` are the only places that construct concrete implementations.
Everything else receives what it needs.

- `Dio()` constructed inside a data source is a **Should fix**: the timeouts and interceptors
  configured in `dio_client.dart` then apply to some requests and not others, and the ones that
  skip them are invisible.
- **`getIt<T>()` called from inside a Cubit or a repository is a service locator in disguise** —
  the dependency stops appearing in the constructor, so the test that needs to replace it has
  to configure the global container instead. **Should fix.** Calling `getIt<SlipCubit>()` at a
  `BlocProvider(create:)` is the intended use and is fine; the rule is that resolution happens
  at the composition root, not in the middle of the tree.
- **`registerFactory` for Cubits, `registerLazySingleton` for everything below.** A Cubit
  registered as a singleton outlives its page: it comes back holding the previous screen's
  state, and a late `emit` lands on a Cubit the framework already closed. **Should fix**, and
  the symptom (stale slip on second visit) rarely gets traced back to the registration.

## The layer that is deliberately absent

There is no domain `Entity` distinct from `Slip`, and no mapper between them — `docs/mobile.md`
§3 declines it by name, because the mapper would convert a `Slip` into an identical `Slip`.
Adding one is not a neutral refactor; it is a disagreement with a doc, and a review that
recommends it must say so. The moment it becomes right is when Create or Convert needs a
UI-only shape the API does not return.

## Questions worth asking

- Could this Cubit be handed a different repository implementation and still be correct?
- Is there any `dio` vocabulary above `data/`?
- Would a second feature need to import anything from this one?
- Is anything resolved from `get_it` outside the composition root?
- Is this abstraction hiding a real swap, or just adding a file?
