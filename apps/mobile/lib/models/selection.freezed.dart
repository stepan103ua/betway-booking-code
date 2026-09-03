// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Selection {

 String get outcomeId; String get marketName; String get outcomeName; String get eventName; String get league; String get kickoffAt; double get odds; bool get isActive;
/// Create a copy of Selection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectionCopyWith<Selection> get copyWith => _$SelectionCopyWithImpl<Selection>(this as Selection, _$identity);

  /// Serializes this Selection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Selection&&(identical(other.outcomeId, outcomeId) || other.outcomeId == outcomeId)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.outcomeName, outcomeName) || other.outcomeName == outcomeName)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.league, league) || other.league == league)&&(identical(other.kickoffAt, kickoffAt) || other.kickoffAt == kickoffAt)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outcomeId,marketName,outcomeName,eventName,league,kickoffAt,odds,isActive);

@override
String toString() {
  return 'Selection(outcomeId: $outcomeId, marketName: $marketName, outcomeName: $outcomeName, eventName: $eventName, league: $league, kickoffAt: $kickoffAt, odds: $odds, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $SelectionCopyWith<$Res>  {
  factory $SelectionCopyWith(Selection value, $Res Function(Selection) _then) = _$SelectionCopyWithImpl;
@useResult
$Res call({
 String outcomeId, String marketName, String outcomeName, String eventName, String league, String kickoffAt, double odds, bool isActive
});




}
/// @nodoc
class _$SelectionCopyWithImpl<$Res>
    implements $SelectionCopyWith<$Res> {
  _$SelectionCopyWithImpl(this._self, this._then);

  final Selection _self;
  final $Res Function(Selection) _then;

/// Create a copy of Selection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outcomeId = null,Object? marketName = null,Object? outcomeName = null,Object? eventName = null,Object? league = null,Object? kickoffAt = null,Object? odds = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
outcomeId: null == outcomeId ? _self.outcomeId : outcomeId // ignore: cast_nullable_to_non_nullable
as String,marketName: null == marketName ? _self.marketName : marketName // ignore: cast_nullable_to_non_nullable
as String,outcomeName: null == outcomeName ? _self.outcomeName : outcomeName // ignore: cast_nullable_to_non_nullable
as String,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,league: null == league ? _self.league : league // ignore: cast_nullable_to_non_nullable
as String,kickoffAt: null == kickoffAt ? _self.kickoffAt : kickoffAt // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Selection].
extension SelectionPatterns on Selection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Selection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Selection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Selection value)  $default,){
final _that = this;
switch (_that) {
case _Selection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Selection value)?  $default,){
final _that = this;
switch (_that) {
case _Selection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String outcomeId,  String marketName,  String outcomeName,  String eventName,  String league,  String kickoffAt,  double odds,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Selection() when $default != null:
return $default(_that.outcomeId,_that.marketName,_that.outcomeName,_that.eventName,_that.league,_that.kickoffAt,_that.odds,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String outcomeId,  String marketName,  String outcomeName,  String eventName,  String league,  String kickoffAt,  double odds,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _Selection():
return $default(_that.outcomeId,_that.marketName,_that.outcomeName,_that.eventName,_that.league,_that.kickoffAt,_that.odds,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String outcomeId,  String marketName,  String outcomeName,  String eventName,  String league,  String kickoffAt,  double odds,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _Selection() when $default != null:
return $default(_that.outcomeId,_that.marketName,_that.outcomeName,_that.eventName,_that.league,_that.kickoffAt,_that.odds,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Selection implements Selection {
  const _Selection({required this.outcomeId, required this.marketName, required this.outcomeName, required this.eventName, required this.league, required this.kickoffAt, required this.odds, required this.isActive});
  factory _Selection.fromJson(Map<String, dynamic> json) => _$SelectionFromJson(json);

@override final  String outcomeId;
@override final  String marketName;
@override final  String outcomeName;
@override final  String eventName;
@override final  String league;
@override final  String kickoffAt;
@override final  double odds;
@override final  bool isActive;

/// Create a copy of Selection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectionCopyWith<_Selection> get copyWith => __$SelectionCopyWithImpl<_Selection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SelectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Selection&&(identical(other.outcomeId, outcomeId) || other.outcomeId == outcomeId)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.outcomeName, outcomeName) || other.outcomeName == outcomeName)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.league, league) || other.league == league)&&(identical(other.kickoffAt, kickoffAt) || other.kickoffAt == kickoffAt)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outcomeId,marketName,outcomeName,eventName,league,kickoffAt,odds,isActive);

@override
String toString() {
  return 'Selection(outcomeId: $outcomeId, marketName: $marketName, outcomeName: $outcomeName, eventName: $eventName, league: $league, kickoffAt: $kickoffAt, odds: $odds, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$SelectionCopyWith<$Res> implements $SelectionCopyWith<$Res> {
  factory _$SelectionCopyWith(_Selection value, $Res Function(_Selection) _then) = __$SelectionCopyWithImpl;
@override @useResult
$Res call({
 String outcomeId, String marketName, String outcomeName, String eventName, String league, String kickoffAt, double odds, bool isActive
});




}
/// @nodoc
class __$SelectionCopyWithImpl<$Res>
    implements _$SelectionCopyWith<$Res> {
  __$SelectionCopyWithImpl(this._self, this._then);

  final _Selection _self;
  final $Res Function(_Selection) _then;

/// Create a copy of Selection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outcomeId = null,Object? marketName = null,Object? outcomeName = null,Object? eventName = null,Object? league = null,Object? kickoffAt = null,Object? odds = null,Object? isActive = null,}) {
  return _then(_Selection(
outcomeId: null == outcomeId ? _self.outcomeId : outcomeId // ignore: cast_nullable_to_non_nullable
as String,marketName: null == marketName ? _self.marketName : marketName // ignore: cast_nullable_to_non_nullable
as String,outcomeName: null == outcomeName ? _self.outcomeName : outcomeName // ignore: cast_nullable_to_non_nullable
as String,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,league: null == league ? _self.league : league // ignore: cast_nullable_to_non_nullable
as String,kickoffAt: null == kickoffAt ? _self.kickoffAt : kickoffAt // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
