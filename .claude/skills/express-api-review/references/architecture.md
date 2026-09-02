# Architecture — layers, seams, and what belongs where

The structure is fixed in `docs/backend.md` §3. The value of it is not tidiness; it is that
each layer can be reasoned about and tested without the ones below it.

## Layer boundaries

| Layer | Owns | Must never |
|---|---|---|
| `routes/` | path, method, validation middleware, wiring | contain logic, call a provider, catch errors |
| `controllers/` | read validated input, call one service, send the result | branch on upstream behaviour, decide cache policy, build an error body |
| `services/` | business logic, cache policy, Convert composition | know Betway's field names or URLs |
| `providers/` | one upstream, normalized into our DTOs | leak upstream shape past its own return type |
| `lib/`, `middleware/` | cross-cutting mechanics | contain endpoint-specific logic |

The test that catches most violations: **could you swap the provider for a different bookmaker
and change nothing in `services/`?** If a service references `priceDecimal`, `outcomeId`
construction, or a Betway URL, the answer is no and normalization landed in the wrong layer.

The second test: **could you delete Express and keep the services?** If a service takes a
`Request` or returns a status code, HTTP has leaked downward.

## The provider seam

`BookingCodeProvider` is the one abstraction in the system that earns its keep, and it earns
it for a stated reason: swapping to `FixturesProvider` keeps the demo alive when Betway is
down, and a second bookmaker plugs in here rather than rippling upward.

- Services depend on the interface, never on `betway.provider.ts`. An import of the concrete
  class anywhere outside `src/index.ts` is a **Blocker** — it is the one thing the design
  exists to prevent.
- Both implementations must satisfy the same interface honestly. A `FixturesProvider` that
  throws where `BetwayProvider` returns data makes offline tests pass against behaviour that
  does not exist.
- New provider method → add it to the interface first, then both implementations. An interface
  that has drifted behind its implementations has stopped being a contract.

Resist adding a second abstraction beside it. A repository layer over a cache, or a generic
`HttpClient` wrapper with one caller, is indirection without a swap behind it.

## Composition root

`src/index.ts` is the only place that constructs concrete implementations and reads
configuration into them. Everything else receives its dependencies.

Watch for: `new BetwayProvider()` inside a service, `process.env` read outside `config.ts`, a
module-level singleton cache client imported directly by a service. Each one makes the thing
that uses it untestable without the real dependency, which is usually discovered later, in a
test that mysteriously needs a network.

## DTO purity

`packages/contracts` defines the response shapes once. The rule is one sentence: **a client
must not be able to tell which bookmaker answered.**

Concretely, inside a provider and nowhere else: `priceDecimal` → `odds`, `eventEpoch` (unix
seconds) → ISO `kickoffAt`, and `isMarketActive`/`isEventActive`/`isOutcomeActive` collapse
into one `isActive`.

- A response field not in `docs/backend-api.md` §0 is a **Blocker**: it is an undocumented
  contract change, and the web and Flutter clients both mirror that file.
- A locally redeclared `type Slip` is a **Should fix**. It will drift, and the drift surfaces
  at runtime in front of whoever is looking.
- Spreading an upstream object into a response (`...selection`) is a **Blocker** even when the
  visible fields look right — it ships whatever upstream adds next, unreviewed.

## Questions worth asking

- Could this service be handed a different provider and still be correct?
- Is there any Betway vocabulary above `providers/`?
- Does every response field appear in `docs/backend-api.md` §0?
- Is anything constructed outside the composition root that should be injected?
- Is this abstraction hiding a real swap, or just adding a file?
