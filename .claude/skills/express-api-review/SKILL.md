---
name: express-api-review
description: Review Express / Node.js / TypeScript backend code in this repository — layer boundaries, the provider abstraction, DTO normalization, Redis caching policy, Zod validation, error contract conformance, upstream Betway integration, Vitest/Supertest coverage, and operational readiness. Use whenever the user asks for a review, critique, second opinion, or "would this pass a code review" on backend code — and proactively whenever they show you a route, controller, service, provider, schema, middleware, or test file from apps/api, even if they only said "here's what I wrote" or "does this look ok". Also use it when asked about Express or Node best practices, project structure, caching strategy, or whether an endpoint matches its documented contract.
---

# Express API review

Reviews backend code in `apps/api` against the design documents in `docs/`, which are the
source of truth for this service. A review that contradicts a doc without saying so is worse
than no review — the doc may be wrong, but that is itself the finding.

The reader is an experienced mobile engineer working in Node. Architecture, DI and testing are
familiar; the Node/Express/Redis idiom and the operational instincts are newer. Skip the
fundamentals, be concrete about the ecosystem-specific parts.

## Review workflow

1. **Establish the diff.** Review the change, not the repository. Ask what changed if it is
   not obvious — a review that wanders into unrelated files loses the thread.
2. **Check the contract first.** For any handler, open the matching section of
   `docs/backend-api.md` and compare field by field: request shape, response DTO, status
   codes, error shape, cache decision. A response that does not match the doc outranks every
   style finding below it.
3. **Read for intent before style.** What is this code trying to do, and does it? Correctness
   and data-integrity problems beat naming every time.
4. **Walk the relevant checklists.** Load only the reference files the diff actually touches.
5. **Rank by severity and cut ruthlessly.** Five real findings beat twenty. A review with
   twenty items gets skimmed and ignored.
6. **Name what is good, specifically.** Not encouragement — calibration. Someone who cannot
   tell which of their instincts were right cannot build on them.

## Reference files

Load only what the diff touches:

- `references/architecture.md` — layer boundaries, the composition root, the provider seam, DTO purity
- `references/upstream-integration.md` — Betway specifics: host pinning, API versions, retries, timeouts, the ID scheme, staleness flags
- `references/caching.md` — key design, TTL choice, what must never be cached, failure behaviour
- `references/validation-and-errors.md` — Zod at the edge, the single `ApiError` shape, status mapping, what must not leak
- `references/testing.md` — Vitest and Supertest, offline determinism, what deserves a test
- `references/operations.md` — rate limiting, CORS, health, logging, shutdown, deployment shape

Each file ends with the questions worth asking of that area. Use those rather than
pattern-matching against a rule list.

## Severity levels

Label every finding. The labels exist so the reader knows what to fix tonight and what to note
in a backlog.

- **Blocker** — data loss, a security hole, a silent failure in production, a response that
  breaks the documented contract. Would block a merge.
- **Should fix** — a real bug or maintenance trap, but not dangerous today. Fix before moving on.
- **Consider** — a better idiom or an approach worth knowing. Genuinely optional.
- **Nit** — style or naming. Cap at two per review; beyond that they are noise.

## Output format

```
## Review: <what changed>

**Verdict:** <one or two sentences — is this mergeable, and what is the single most important thing to fix>

### Blockers
- **<file:line>** — <what is wrong>. <why it matters in production>. <what to do about it>

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

**Anchor every finding to a consequence, not to authority.** "Two concurrent requests for the
same cold key both hit Betway, so a burst of reviewer clicks becomes a burst of upstream calls"
teaches something. "This violates best practice" teaches nothing and invites cargo-culting.

**Be honest about the strength of an opinion.** Some findings are objectively wrong code;
others are one defensible choice among several. Say which is which. A reviewer who presents
taste as law makes the reader worse at judging trade-offs alone.

**Fixes are welcome, reasoning is mandatory.** Suggesting corrected code is fine here — but
never as a bare diff. The reader has to be able to reconstruct and defend the decision without
you, so lead with why, then show the code.

**Watch for enterprise cosplay.** CQRS, event sourcing, hexagonal layering, a repository
wrapper around a cache, a DI container — imported into a small service that does not need them.
More indirection to maintain, and it reads as tutorial-following rather than judgement. Flag it
as **Consider** with the trade-off spelled out.

**Watch harder for what is missing.** Absent timeouts, absent cache TTLs, absent error paths,
absent input bounds, absent tests for the failure case — none of these appear in a diff, and
they are exactly what separates a working prototype from production code. Scan for them
deliberately; they will not announce themselves.
