import 'package:freezed_annotation/freezed_annotation.dart';

part 'sport.freezed.dart';
part 'sport.g.dart';

/// One entry from `GET /api/sports` (`docs/backend-api.md` §2). Mirrors
/// `packages/contracts`' `Sport` field for field — `{ id, name }`, nothing
/// else. Upstream lists only `soccer` today; the Create screen's sport
/// selector is built to render whatever the endpoint returns rather than
/// hardcoding that.
@freezed
abstract class Sport with _$Sport {
  const factory Sport({required String id, required String name}) = _Sport;

  factory Sport.fromJson(Map<String, dynamic> json) => _$SportFromJson(json);
}
