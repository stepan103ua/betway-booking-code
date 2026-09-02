# Architecture diagrams — Betway Nigeria Booking Code Product

Three diagrams: how the pieces fit together, then the two flows that matter — Decode (a
read, cached) and Convert (a composition of two Betway calls, not a call of its own).

---

## 1. System overview

```mermaid
flowchart LR
    subgraph Clients["Clients"]
        Web["Next.js Web\n(apps/web)"]
        Mobile["Flutter App\n(apps/mobile)"]
    end

    subgraph API["apps/api — Express"]
        Routes["Routes"]
        Services["Services\n(normalize, cache, compose)"]
        Provider["BookingCodeProvider\n(interface)"]
    end

    Redis[("Redis\nresolve / events / sports\ncache, TTL 30s–1h")]
    Betway[["Betway NG\n(FindBookABet, BookABet,\nBetBook, Widget)"]]
    Fixtures[("Local fixtures\n(committed JSON)")]

    Web -- "HTTPS, JSON" --> Routes
    Mobile -- "HTTPS, JSON" --> Routes
    Routes --> Services
    Services <-- "read-through cache" --> Redis
    Services --> Provider
    Provider -- "live" --> Betway
    Provider -. "if Betway is unreachable" .-> Fixtures
```

Both clients are equal, plain HTTP consumers of one API — neither talks to Betway directly.
`BookingCodeProvider` is the one seam in the whole system: swap `Betway` for `Fixtures` here
and nothing above it (Services, Routes, either client) changes. No database in this picture —
Redis is the only store, and it's a cache, not a source of truth (`docs/backend.md` §1, §5).

---

## 2. Decode — a cached read

```mermaid
sequenceDiagram
    actor U as User
    participant C as Client (Web / Mobile)
    participant A as API
    participant R as Redis
    participant B as Betway

    U->>C: Paste booking code
    C->>A: POST /api/booking-codes/resolve
    A->>R: GET resolve:{code}

    alt cached
        R-->>A: Slip (cached)
        A-->>C: 200 Slip
        C-->>U: Render slip card
    else not cached
        A->>B: POST FindBookABet
        alt code exists
            B-->>A: selections[]
            A->>A: normalize → Slip DTO
            A->>R: SET resolve:{code}, TTL 30–60s
            A-->>C: 200 Slip
            C-->>U: Render slip card
        else invalid code
            B-->>A: 400 BookABetInvalidCode
            A-->>C: 404 ApiError
            C-->>U: "That code doesn't look right"
        end
    end
```

The cache sits in front of every request, not just repeated ones — a code decoded once by
any user is instant for the next 30–60 seconds for anyone else, and Betway sees one call
instead of many.

---

## 3. Convert — composition, not a Betway endpoint

```mermaid
sequenceDiagram
    actor U as User
    participant C as Client
    participant A as API
    participant B as Betway

    U->>C: Submit code, uncheck dead/unwanted legs
    C->>A: POST /api/booking-codes/convert

    A->>B: POST FindBookABet (resolve original code)
    B-->>A: selections[]

    A->>A: drop unchecked + inactive legs

    A->>B: POST BookABet (encode remaining legs)
    B-->>A: new bookingCode

    A-->>C: 200 ConvertResult (old code, new code, odds before/after)
    C-->>U: Show before/after diff
```

Betway has no "convert" endpoint — Convert is `resolve` then `encode`, composed entirely on
our side (`docs/backend-api.md` §1). On a single bookmaker this is close to a formality; the
real complexity Convert is built to eventually carry is cross-bookmaker mapping, which this
composition point is the seam for, not something this assessment implements.