/// Shared error hierarchy — every feature's repository throws one of these,
/// every feature's Cubit catches one of these. `docs/mobile.md` §5.
///
/// Decode's whole failure surface is "the code doesn't exist" (404), "the
/// network failed", or "something else went wrong". Create is where the
/// "richer, per-error-code hierarchy" that section anticipated actually
/// earns its place (`docs/mobile.md` §9): `POST /api/booking-codes` has two
/// distinct 400s a client can act on differently — [TooManyOutcomesFailure]
/// ("remove a leg") and [OutcomesUnavailableFailure] ("refresh and re-pick").
/// Both are told apart by the `error` field, which the contract
/// (`packages/contracts`) says clients branch on.
///
/// `Either<Failure, T>` (`dartz`/`fpdart`) is the more "purist" alternative
/// to throw/catch — deliberately not used here, per the same section: it's a
/// second way to express the three-branch outcome below, and `bloc_test`
/// verifies the same emitted states either way.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Check your connection and try again.');
}

class InvalidCodeFailure extends Failure {
  const InvalidCodeFailure() : super("That code doesn't look right.");
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// `404` from `GET /api/events/:eventId/markets` — the event is unknown or has
/// nothing priced on it. Distinct from [InvalidCodeFailure] because the two
/// read differently in the UI: one is "that's not a code", this is "there's
/// nothing to bet on here yet".
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// `400 too_many_outcomes` from `POST /api/booking-codes`. The picker caps the
/// draft at 20 client-side, so this should not normally be reachable — it
/// exists so a server that changes its cap still surfaces something the user
/// can act on rather than a generic error.
class TooManyOutcomesFailure extends Failure {
  const TooManyOutcomesFailure(super.message);
}

/// `400 outcomes_unavailable` from `POST /api/booking-codes` and `/convert` —
/// one or more selections went off between resolving and (re)generating (the
/// soccer feed is largely eSoccer, kicking off every ~15 min, so a leg can die
/// mid-flow). Carries the server's own message, which is written to be shown
/// verbatim.
class OutcomesUnavailableFailure extends Failure {
  const OutcomesUnavailableFailure(super.message);
}

/// `400 empty_slip` from `POST /api/booking-codes/convert` — the drops (asked
/// for, plus every dead leg) leave nothing to reissue. The server's message
/// tells the two apart ("dropping those leaves nothing" vs "none can still be
/// bet").
class EmptySlipFailure extends Failure {
  const EmptySlipFailure(super.message);
}

/// `400 conflicting_selections` from `POST /api/booking-codes` and `/convert` —
/// two or more of the (kept) legs are on the same event, which a booking code
/// cannot combine (`docs/betway-api.md` §3). The Create picker prevents this;
/// Convert can hit it on a code that was already conflicting.
class ConflictingSelectionsFailure extends Failure {
  const ConflictingSelectionsFailure(super.message);
}
