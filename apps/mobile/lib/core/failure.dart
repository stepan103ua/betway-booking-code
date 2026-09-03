/// Shared error hierarchy — every feature's repository throws one of these,
/// every feature's Cubit catches one of these. `docs/mobile.md` §5, kept to
/// the exact three shapes it specifies: Decode's whole failure surface is
/// "the code doesn't exist" (404), "the network failed", or "something else
/// went wrong" — a richer, per-error-code hierarchy is worth it once a
/// feature (Create, Convert) actually has more than one 4xx outcome to tell
/// apart.
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
