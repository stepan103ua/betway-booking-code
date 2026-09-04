// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'convert_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConvertResult {

 String get bookingCode; double get totalOdds; String? get expiresAt; int? get usageCount; List<Selection> get selections; String get previousBookingCode; double get previousTotalOdds; int get droppedCount;
/// Create a copy of ConvertResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConvertResultCopyWith<ConvertResult> get copyWith => _$ConvertResultCopyWithImpl<ConvertResult>(this as ConvertResult, _$identity);

  /// Serializes this ConvertResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConvertResult&&(identical(other.bookingCode, bookingCode) || other.bookingCode == bookingCode)&&(identical(other.totalOdds, totalOdds) || other.totalOdds == totalOdds)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&const DeepCollectionEquality().equals(other.selections, selections)&&(identical(other.previousBookingCode, previousBookingCode) || other.previousBookingCode == previousBookingCode)&&(identical(other.previousTotalOdds, previousTotalOdds) || other.previousTotalOdds == previousTotalOdds)&&(identical(other.droppedCount, droppedCount) || other.droppedCount == droppedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingCode,totalOdds,expiresAt,usageCount,const DeepCollectionEquality().hash(selections),previousBookingCode,previousTotalOdds,droppedCount);

@override
String toString() {
  return 'ConvertResult(bookingCode: $bookingCode, totalOdds: $totalOdds, expiresAt: $expiresAt, usageCount: $usageCount, selections: $selections, previousBookingCode: $previousBookingCode, previousTotalOdds: $previousTotalOdds, droppedCount: $droppedCount)';
}


}

/// @nodoc
abstract mixin class $ConvertResultCopyWith<$Res>  {
  factory $ConvertResultCopyWith(ConvertResult value, $Res Function(ConvertResult) _then) = _$ConvertResultCopyWithImpl;
@useResult
$Res call({
 String bookingCode, double totalOdds, String? expiresAt, int? usageCount, List<Selection> selections, String previousBookingCode, double previousTotalOdds, int droppedCount
});




}
/// @nodoc
class _$ConvertResultCopyWithImpl<$Res>
    implements $ConvertResultCopyWith<$Res> {
  _$ConvertResultCopyWithImpl(this._self, this._then);

  final ConvertResult _self;
  final $Res Function(ConvertResult) _then;

/// Create a copy of ConvertResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingCode = null,Object? totalOdds = null,Object? expiresAt = freezed,Object? usageCount = freezed,Object? selections = null,Object? previousBookingCode = null,Object? previousTotalOdds = null,Object? droppedCount = null,}) {
  return _then(_self.copyWith(
bookingCode: null == bookingCode ? _self.bookingCode : bookingCode // ignore: cast_nullable_to_non_nullable
as String,totalOdds: null == totalOdds ? _self.totalOdds : totalOdds // ignore: cast_nullable_to_non_nullable
as double,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,usageCount: freezed == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int?,selections: null == selections ? _self.selections : selections // ignore: cast_nullable_to_non_nullable
as List<Selection>,previousBookingCode: null == previousBookingCode ? _self.previousBookingCode : previousBookingCode // ignore: cast_nullable_to_non_nullable
as String,previousTotalOdds: null == previousTotalOdds ? _self.previousTotalOdds : previousTotalOdds // ignore: cast_nullable_to_non_nullable
as double,droppedCount: null == droppedCount ? _self.droppedCount : droppedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ConvertResult].
extension ConvertResultPatterns on ConvertResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConvertResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConvertResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConvertResult value)  $default,){
final _that = this;
switch (_that) {
case _ConvertResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConvertResult value)?  $default,){
final _that = this;
switch (_that) {
case _ConvertResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookingCode,  double totalOdds,  String? expiresAt,  int? usageCount,  List<Selection> selections,  String previousBookingCode,  double previousTotalOdds,  int droppedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConvertResult() when $default != null:
return $default(_that.bookingCode,_that.totalOdds,_that.expiresAt,_that.usageCount,_that.selections,_that.previousBookingCode,_that.previousTotalOdds,_that.droppedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookingCode,  double totalOdds,  String? expiresAt,  int? usageCount,  List<Selection> selections,  String previousBookingCode,  double previousTotalOdds,  int droppedCount)  $default,) {final _that = this;
switch (_that) {
case _ConvertResult():
return $default(_that.bookingCode,_that.totalOdds,_that.expiresAt,_that.usageCount,_that.selections,_that.previousBookingCode,_that.previousTotalOdds,_that.droppedCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookingCode,  double totalOdds,  String? expiresAt,  int? usageCount,  List<Selection> selections,  String previousBookingCode,  double previousTotalOdds,  int droppedCount)?  $default,) {final _that = this;
switch (_that) {
case _ConvertResult() when $default != null:
return $default(_that.bookingCode,_that.totalOdds,_that.expiresAt,_that.usageCount,_that.selections,_that.previousBookingCode,_that.previousTotalOdds,_that.droppedCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConvertResult implements ConvertResult {
  const _ConvertResult({required this.bookingCode, required this.totalOdds, required this.expiresAt, required this.usageCount, required final  List<Selection> selections, required this.previousBookingCode, required this.previousTotalOdds, required this.droppedCount}): _selections = selections;
  factory _ConvertResult.fromJson(Map<String, dynamic> json) => _$ConvertResultFromJson(json);

@override final  String bookingCode;
@override final  double totalOdds;
@override final  String? expiresAt;
@override final  int? usageCount;
 final  List<Selection> _selections;
@override List<Selection> get selections {
  if (_selections is EqualUnmodifiableListView) return _selections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selections);
}

@override final  String previousBookingCode;
@override final  double previousTotalOdds;
@override final  int droppedCount;

/// Create a copy of ConvertResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConvertResultCopyWith<_ConvertResult> get copyWith => __$ConvertResultCopyWithImpl<_ConvertResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConvertResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConvertResult&&(identical(other.bookingCode, bookingCode) || other.bookingCode == bookingCode)&&(identical(other.totalOdds, totalOdds) || other.totalOdds == totalOdds)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&const DeepCollectionEquality().equals(other._selections, _selections)&&(identical(other.previousBookingCode, previousBookingCode) || other.previousBookingCode == previousBookingCode)&&(identical(other.previousTotalOdds, previousTotalOdds) || other.previousTotalOdds == previousTotalOdds)&&(identical(other.droppedCount, droppedCount) || other.droppedCount == droppedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingCode,totalOdds,expiresAt,usageCount,const DeepCollectionEquality().hash(_selections),previousBookingCode,previousTotalOdds,droppedCount);

@override
String toString() {
  return 'ConvertResult(bookingCode: $bookingCode, totalOdds: $totalOdds, expiresAt: $expiresAt, usageCount: $usageCount, selections: $selections, previousBookingCode: $previousBookingCode, previousTotalOdds: $previousTotalOdds, droppedCount: $droppedCount)';
}


}

/// @nodoc
abstract mixin class _$ConvertResultCopyWith<$Res> implements $ConvertResultCopyWith<$Res> {
  factory _$ConvertResultCopyWith(_ConvertResult value, $Res Function(_ConvertResult) _then) = __$ConvertResultCopyWithImpl;
@override @useResult
$Res call({
 String bookingCode, double totalOdds, String? expiresAt, int? usageCount, List<Selection> selections, String previousBookingCode, double previousTotalOdds, int droppedCount
});




}
/// @nodoc
class __$ConvertResultCopyWithImpl<$Res>
    implements _$ConvertResultCopyWith<$Res> {
  __$ConvertResultCopyWithImpl(this._self, this._then);

  final _ConvertResult _self;
  final $Res Function(_ConvertResult) _then;

/// Create a copy of ConvertResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingCode = null,Object? totalOdds = null,Object? expiresAt = freezed,Object? usageCount = freezed,Object? selections = null,Object? previousBookingCode = null,Object? previousTotalOdds = null,Object? droppedCount = null,}) {
  return _then(_ConvertResult(
bookingCode: null == bookingCode ? _self.bookingCode : bookingCode // ignore: cast_nullable_to_non_nullable
as String,totalOdds: null == totalOdds ? _self.totalOdds : totalOdds // ignore: cast_nullable_to_non_nullable
as double,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,usageCount: freezed == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int?,selections: null == selections ? _self._selections : selections // ignore: cast_nullable_to_non_nullable
as List<Selection>,previousBookingCode: null == previousBookingCode ? _self.previousBookingCode : previousBookingCode // ignore: cast_nullable_to_non_nullable
as String,previousTotalOdds: null == previousTotalOdds ? _self.previousTotalOdds : previousTotalOdds // ignore: cast_nullable_to_non_nullable
as double,droppedCount: null == droppedCount ? _self.droppedCount : droppedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
