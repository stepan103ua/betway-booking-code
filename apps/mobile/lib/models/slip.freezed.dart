// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Slip {

 String get bookingCode; double get totalOdds; String? get expiresAt; int? get usageCount; List<Selection> get selections;
/// Create a copy of Slip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlipCopyWith<Slip> get copyWith => _$SlipCopyWithImpl<Slip>(this as Slip, _$identity);

  /// Serializes this Slip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Slip&&(identical(other.bookingCode, bookingCode) || other.bookingCode == bookingCode)&&(identical(other.totalOdds, totalOdds) || other.totalOdds == totalOdds)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&const DeepCollectionEquality().equals(other.selections, selections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingCode,totalOdds,expiresAt,usageCount,const DeepCollectionEquality().hash(selections));

@override
String toString() {
  return 'Slip(bookingCode: $bookingCode, totalOdds: $totalOdds, expiresAt: $expiresAt, usageCount: $usageCount, selections: $selections)';
}


}

/// @nodoc
abstract mixin class $SlipCopyWith<$Res>  {
  factory $SlipCopyWith(Slip value, $Res Function(Slip) _then) = _$SlipCopyWithImpl;
@useResult
$Res call({
 String bookingCode, double totalOdds, String? expiresAt, int? usageCount, List<Selection> selections
});




}
/// @nodoc
class _$SlipCopyWithImpl<$Res>
    implements $SlipCopyWith<$Res> {
  _$SlipCopyWithImpl(this._self, this._then);

  final Slip _self;
  final $Res Function(Slip) _then;

/// Create a copy of Slip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingCode = null,Object? totalOdds = null,Object? expiresAt = freezed,Object? usageCount = freezed,Object? selections = null,}) {
  return _then(_self.copyWith(
bookingCode: null == bookingCode ? _self.bookingCode : bookingCode // ignore: cast_nullable_to_non_nullable
as String,totalOdds: null == totalOdds ? _self.totalOdds : totalOdds // ignore: cast_nullable_to_non_nullable
as double,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,usageCount: freezed == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int?,selections: null == selections ? _self.selections : selections // ignore: cast_nullable_to_non_nullable
as List<Selection>,
  ));
}

}


/// Adds pattern-matching-related methods to [Slip].
extension SlipPatterns on Slip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Slip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Slip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Slip value)  $default,){
final _that = this;
switch (_that) {
case _Slip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Slip value)?  $default,){
final _that = this;
switch (_that) {
case _Slip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookingCode,  double totalOdds,  String? expiresAt,  int? usageCount,  List<Selection> selections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Slip() when $default != null:
return $default(_that.bookingCode,_that.totalOdds,_that.expiresAt,_that.usageCount,_that.selections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookingCode,  double totalOdds,  String? expiresAt,  int? usageCount,  List<Selection> selections)  $default,) {final _that = this;
switch (_that) {
case _Slip():
return $default(_that.bookingCode,_that.totalOdds,_that.expiresAt,_that.usageCount,_that.selections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookingCode,  double totalOdds,  String? expiresAt,  int? usageCount,  List<Selection> selections)?  $default,) {final _that = this;
switch (_that) {
case _Slip() when $default != null:
return $default(_that.bookingCode,_that.totalOdds,_that.expiresAt,_that.usageCount,_that.selections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Slip implements Slip {
  const _Slip({required this.bookingCode, required this.totalOdds, required this.expiresAt, required this.usageCount, required final  List<Selection> selections}): _selections = selections;
  factory _Slip.fromJson(Map<String, dynamic> json) => _$SlipFromJson(json);

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


/// Create a copy of Slip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlipCopyWith<_Slip> get copyWith => __$SlipCopyWithImpl<_Slip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Slip&&(identical(other.bookingCode, bookingCode) || other.bookingCode == bookingCode)&&(identical(other.totalOdds, totalOdds) || other.totalOdds == totalOdds)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&const DeepCollectionEquality().equals(other._selections, _selections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookingCode,totalOdds,expiresAt,usageCount,const DeepCollectionEquality().hash(_selections));

@override
String toString() {
  return 'Slip(bookingCode: $bookingCode, totalOdds: $totalOdds, expiresAt: $expiresAt, usageCount: $usageCount, selections: $selections)';
}


}

/// @nodoc
abstract mixin class _$SlipCopyWith<$Res> implements $SlipCopyWith<$Res> {
  factory _$SlipCopyWith(_Slip value, $Res Function(_Slip) _then) = __$SlipCopyWithImpl;
@override @useResult
$Res call({
 String bookingCode, double totalOdds, String? expiresAt, int? usageCount, List<Selection> selections
});




}
/// @nodoc
class __$SlipCopyWithImpl<$Res>
    implements _$SlipCopyWith<$Res> {
  __$SlipCopyWithImpl(this._self, this._then);

  final _Slip _self;
  final $Res Function(_Slip) _then;

/// Create a copy of Slip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingCode = null,Object? totalOdds = null,Object? expiresAt = freezed,Object? usageCount = freezed,Object? selections = null,}) {
  return _then(_Slip(
bookingCode: null == bookingCode ? _self.bookingCode : bookingCode // ignore: cast_nullable_to_non_nullable
as String,totalOdds: null == totalOdds ? _self.totalOdds : totalOdds // ignore: cast_nullable_to_non_nullable
as double,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,usageCount: freezed == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int?,selections: null == selections ? _self._selections : selections // ignore: cast_nullable_to_non_nullable
as List<Selection>,
  ));
}


}

// dart format on
