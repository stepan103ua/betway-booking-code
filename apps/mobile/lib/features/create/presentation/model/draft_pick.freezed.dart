// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_pick.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DraftPick {

 String get outcomeId; String get outcomeLabel; String get marketName; String get eventId; String get eventName; String get league; String get kickoffAt; double get odds;
/// Create a copy of DraftPick
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftPickCopyWith<DraftPick> get copyWith => _$DraftPickCopyWithImpl<DraftPick>(this as DraftPick, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftPick&&(identical(other.outcomeId, outcomeId) || other.outcomeId == outcomeId)&&(identical(other.outcomeLabel, outcomeLabel) || other.outcomeLabel == outcomeLabel)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.league, league) || other.league == league)&&(identical(other.kickoffAt, kickoffAt) || other.kickoffAt == kickoffAt)&&(identical(other.odds, odds) || other.odds == odds));
}


@override
int get hashCode => Object.hash(runtimeType,outcomeId,outcomeLabel,marketName,eventId,eventName,league,kickoffAt,odds);

@override
String toString() {
  return 'DraftPick(outcomeId: $outcomeId, outcomeLabel: $outcomeLabel, marketName: $marketName, eventId: $eventId, eventName: $eventName, league: $league, kickoffAt: $kickoffAt, odds: $odds)';
}


}

/// @nodoc
abstract mixin class $DraftPickCopyWith<$Res>  {
  factory $DraftPickCopyWith(DraftPick value, $Res Function(DraftPick) _then) = _$DraftPickCopyWithImpl;
@useResult
$Res call({
 String outcomeId, String outcomeLabel, String marketName, String eventId, String eventName, String league, String kickoffAt, double odds
});




}
/// @nodoc
class _$DraftPickCopyWithImpl<$Res>
    implements $DraftPickCopyWith<$Res> {
  _$DraftPickCopyWithImpl(this._self, this._then);

  final DraftPick _self;
  final $Res Function(DraftPick) _then;

/// Create a copy of DraftPick
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outcomeId = null,Object? outcomeLabel = null,Object? marketName = null,Object? eventId = null,Object? eventName = null,Object? league = null,Object? kickoffAt = null,Object? odds = null,}) {
  return _then(_self.copyWith(
outcomeId: null == outcomeId ? _self.outcomeId : outcomeId // ignore: cast_nullable_to_non_nullable
as String,outcomeLabel: null == outcomeLabel ? _self.outcomeLabel : outcomeLabel // ignore: cast_nullable_to_non_nullable
as String,marketName: null == marketName ? _self.marketName : marketName // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,league: null == league ? _self.league : league // ignore: cast_nullable_to_non_nullable
as String,kickoffAt: null == kickoffAt ? _self.kickoffAt : kickoffAt // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftPick].
extension DraftPickPatterns on DraftPick {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftPick value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftPick() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftPick value)  $default,){
final _that = this;
switch (_that) {
case _DraftPick():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftPick value)?  $default,){
final _that = this;
switch (_that) {
case _DraftPick() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String outcomeId,  String outcomeLabel,  String marketName,  String eventId,  String eventName,  String league,  String kickoffAt,  double odds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftPick() when $default != null:
return $default(_that.outcomeId,_that.outcomeLabel,_that.marketName,_that.eventId,_that.eventName,_that.league,_that.kickoffAt,_that.odds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String outcomeId,  String outcomeLabel,  String marketName,  String eventId,  String eventName,  String league,  String kickoffAt,  double odds)  $default,) {final _that = this;
switch (_that) {
case _DraftPick():
return $default(_that.outcomeId,_that.outcomeLabel,_that.marketName,_that.eventId,_that.eventName,_that.league,_that.kickoffAt,_that.odds);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String outcomeId,  String outcomeLabel,  String marketName,  String eventId,  String eventName,  String league,  String kickoffAt,  double odds)?  $default,) {final _that = this;
switch (_that) {
case _DraftPick() when $default != null:
return $default(_that.outcomeId,_that.outcomeLabel,_that.marketName,_that.eventId,_that.eventName,_that.league,_that.kickoffAt,_that.odds);case _:
  return null;

}
}

}

/// @nodoc


class _DraftPick extends DraftPick {
  const _DraftPick({required this.outcomeId, required this.outcomeLabel, required this.marketName, required this.eventId, required this.eventName, required this.league, required this.kickoffAt, required this.odds}): super._();
  

@override final  String outcomeId;
@override final  String outcomeLabel;
@override final  String marketName;
@override final  String eventId;
@override final  String eventName;
@override final  String league;
@override final  String kickoffAt;
@override final  double odds;

/// Create a copy of DraftPick
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftPickCopyWith<_DraftPick> get copyWith => __$DraftPickCopyWithImpl<_DraftPick>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftPick&&(identical(other.outcomeId, outcomeId) || other.outcomeId == outcomeId)&&(identical(other.outcomeLabel, outcomeLabel) || other.outcomeLabel == outcomeLabel)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.league, league) || other.league == league)&&(identical(other.kickoffAt, kickoffAt) || other.kickoffAt == kickoffAt)&&(identical(other.odds, odds) || other.odds == odds));
}


@override
int get hashCode => Object.hash(runtimeType,outcomeId,outcomeLabel,marketName,eventId,eventName,league,kickoffAt,odds);

@override
String toString() {
  return 'DraftPick(outcomeId: $outcomeId, outcomeLabel: $outcomeLabel, marketName: $marketName, eventId: $eventId, eventName: $eventName, league: $league, kickoffAt: $kickoffAt, odds: $odds)';
}


}

/// @nodoc
abstract mixin class _$DraftPickCopyWith<$Res> implements $DraftPickCopyWith<$Res> {
  factory _$DraftPickCopyWith(_DraftPick value, $Res Function(_DraftPick) _then) = __$DraftPickCopyWithImpl;
@override @useResult
$Res call({
 String outcomeId, String outcomeLabel, String marketName, String eventId, String eventName, String league, String kickoffAt, double odds
});




}
/// @nodoc
class __$DraftPickCopyWithImpl<$Res>
    implements _$DraftPickCopyWith<$Res> {
  __$DraftPickCopyWithImpl(this._self, this._then);

  final _DraftPick _self;
  final $Res Function(_DraftPick) _then;

/// Create a copy of DraftPick
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outcomeId = null,Object? outcomeLabel = null,Object? marketName = null,Object? eventId = null,Object? eventName = null,Object? league = null,Object? kickoffAt = null,Object? odds = null,}) {
  return _then(_DraftPick(
outcomeId: null == outcomeId ? _self.outcomeId : outcomeId // ignore: cast_nullable_to_non_nullable
as String,outcomeLabel: null == outcomeLabel ? _self.outcomeLabel : outcomeLabel // ignore: cast_nullable_to_non_nullable
as String,marketName: null == marketName ? _self.marketName : marketName // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,league: null == league ? _self.league : league // ignore: cast_nullable_to_non_nullable
as String,kickoffAt: null == kickoffAt ? _self.kickoffAt : kickoffAt // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
