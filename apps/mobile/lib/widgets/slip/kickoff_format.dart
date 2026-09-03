import 'package:intl/intl.dart';

final _kickoffFormat = DateFormat('EEE HH:mm');

/// `Selection.kickoffAt` is UTC ISO-8601 (`docs/backend-api.md` §0, the
/// trailing `Z`). `DateTime.parse` on that gives a UTC `DateTime` —
/// formatting it directly shows a Lagos user a kickoff an hour early (WAT is
/// UTC+1). `.toLocal()` first is not optional here.
String formatKickoff(String kickoffAtIso) {
  return _kickoffFormat.format(DateTime.parse(kickoffAtIso).toLocal());
}

/// The API collapses Betway's three staleness flags into one `isActive`
/// boolean (`docs/backend-api.md` §0) and reports nothing about *why* a leg
/// died. The design system's fixture demo invented specific reasons
/// ("Market closed", "Event started") that no real response can produce —
/// this is the honest, generic replacement for a real dead leg.
const deadLegReason = 'No longer available';
