import 'package:intl/intl.dart';

final _kickoffFormat = DateFormat('EEE HH:mm');
final _usageFormat = NumberFormat.decimalPattern('en_NG');

/// `Selection.kickoffAt` is UTC ISO-8601 (`docs/backend-api.md` §0, the
/// trailing `Z`). `DateTime.parse` on that gives a UTC `DateTime` —
/// formatting it directly shows a Lagos user a kickoff an hour early (WAT is
/// UTC+1). `.toLocal()` first is not optional here.
String formatKickoff(String kickoffAtIso) {
  return _kickoffFormat.format(DateTime.parse(kickoffAtIso).toLocal());
}

/// `Slip.expiresAt` is UTC ISO-8601, non-null only from
/// `GET /api/booking-codes/popular` (`docs/backend-api.md` §1) — `resolve`
/// never populates it. Relative to *now*, not to whatever the API's clock
/// said at request time, so this drifts by however long the response sat in
/// a Redis cache; that's the same up-to-a-minute staleness the TTL already
/// allows for the odds next to it.
String formatExpiry(String expiresAtIso) {
  final target = DateTime.parse(expiresAtIso);
  final diff = target.difference(DateTime.now().toUtc());
  if (diff.isNegative) return 'Expired ${_humanize(-diff)} ago';
  return 'Expires in ${_humanize(diff)}';
}

String _humanize(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours > 0) return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  return '${d.inMinutes}m';
}

/// `en-NG` thousands grouping for usage counts (`4,821 loaded`) — same
/// digit grouping as `en-US`, `NumberFormat.decimalPattern` just needs the
/// right locale name so this reads correctly if that ever changes.
String formatUsageCount(int count) => _usageFormat.format(count);

/// The API collapses Betway's three staleness flags into one `isActive`
/// boolean (`docs/backend-api.md` §0) and reports nothing about *why* a leg
/// died. The design system's fixture demo invented specific reasons
/// ("Market closed", "Event started") that no real response can produce —
/// this is the honest, generic replacement for a real dead leg.
const deadLegReason = 'No longer available';
