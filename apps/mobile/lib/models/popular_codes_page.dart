import 'package:freezed_annotation/freezed_annotation.dart';

import 'slip.dart';

part 'popular_codes_page.freezed.dart';
part 'popular_codes_page.g.dart';

/// `GET /api/booking-codes/popular`'s response (`docs/backend-api.md` §1).
/// `codes` is the same `Slip` shape `/resolve` returns — the only endpoint
/// where `expiresAt` and `usageCount` come back non-null, since it's the
/// one that joins the catalogue's expiry/usage data onto a resolved slip.
///
/// `skip`/`total`/`hasMore` are carried through even though nothing paginates
/// with them yet, so the model doesn't have to change shape the day
/// something does — see the doc's "page on `hasMore`, never on
/// `codes.length`" warning if that day comes.
@freezed
abstract class PopularCodesPage with _$PopularCodesPage {
  const factory PopularCodesPage({
    required List<Slip> codes,
    required int skip,
    required int limit,
    required int total,
    required bool hasMore,
  }) = _PopularCodesPage;

  factory PopularCodesPage.fromJson(Map<String, dynamic> json) =>
      _$PopularCodesPageFromJson(json);
}
