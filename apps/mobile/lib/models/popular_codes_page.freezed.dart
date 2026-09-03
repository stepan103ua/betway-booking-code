// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'popular_codes_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PopularCodesPage {

 List<Slip> get codes; int get skip; int get limit; int get total; bool get hasMore;
/// Create a copy of PopularCodesPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PopularCodesPageCopyWith<PopularCodesPage> get copyWith => _$PopularCodesPageCopyWithImpl<PopularCodesPage>(this as PopularCodesPage, _$identity);

  /// Serializes this PopularCodesPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PopularCodesPage&&const DeepCollectionEquality().equals(other.codes, codes)&&(identical(other.skip, skip) || other.skip == skip)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(codes),skip,limit,total,hasMore);

@override
String toString() {
  return 'PopularCodesPage(codes: $codes, skip: $skip, limit: $limit, total: $total, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $PopularCodesPageCopyWith<$Res>  {
  factory $PopularCodesPageCopyWith(PopularCodesPage value, $Res Function(PopularCodesPage) _then) = _$PopularCodesPageCopyWithImpl;
@useResult
$Res call({
 List<Slip> codes, int skip, int limit, int total, bool hasMore
});




}
/// @nodoc
class _$PopularCodesPageCopyWithImpl<$Res>
    implements $PopularCodesPageCopyWith<$Res> {
  _$PopularCodesPageCopyWithImpl(this._self, this._then);

  final PopularCodesPage _self;
  final $Res Function(PopularCodesPage) _then;

/// Create a copy of PopularCodesPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? codes = null,Object? skip = null,Object? limit = null,Object? total = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
codes: null == codes ? _self.codes : codes // ignore: cast_nullable_to_non_nullable
as List<Slip>,skip: null == skip ? _self.skip : skip // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PopularCodesPage].
extension PopularCodesPagePatterns on PopularCodesPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PopularCodesPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PopularCodesPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PopularCodesPage value)  $default,){
final _that = this;
switch (_that) {
case _PopularCodesPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PopularCodesPage value)?  $default,){
final _that = this;
switch (_that) {
case _PopularCodesPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Slip> codes,  int skip,  int limit,  int total,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PopularCodesPage() when $default != null:
return $default(_that.codes,_that.skip,_that.limit,_that.total,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Slip> codes,  int skip,  int limit,  int total,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _PopularCodesPage():
return $default(_that.codes,_that.skip,_that.limit,_that.total,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Slip> codes,  int skip,  int limit,  int total,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _PopularCodesPage() when $default != null:
return $default(_that.codes,_that.skip,_that.limit,_that.total,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PopularCodesPage implements PopularCodesPage {
  const _PopularCodesPage({required final  List<Slip> codes, required this.skip, required this.limit, required this.total, required this.hasMore}): _codes = codes;
  factory _PopularCodesPage.fromJson(Map<String, dynamic> json) => _$PopularCodesPageFromJson(json);

 final  List<Slip> _codes;
@override List<Slip> get codes {
  if (_codes is EqualUnmodifiableListView) return _codes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_codes);
}

@override final  int skip;
@override final  int limit;
@override final  int total;
@override final  bool hasMore;

/// Create a copy of PopularCodesPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PopularCodesPageCopyWith<_PopularCodesPage> get copyWith => __$PopularCodesPageCopyWithImpl<_PopularCodesPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PopularCodesPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PopularCodesPage&&const DeepCollectionEquality().equals(other._codes, _codes)&&(identical(other.skip, skip) || other.skip == skip)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_codes),skip,limit,total,hasMore);

@override
String toString() {
  return 'PopularCodesPage(codes: $codes, skip: $skip, limit: $limit, total: $total, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$PopularCodesPageCopyWith<$Res> implements $PopularCodesPageCopyWith<$Res> {
  factory _$PopularCodesPageCopyWith(_PopularCodesPage value, $Res Function(_PopularCodesPage) _then) = __$PopularCodesPageCopyWithImpl;
@override @useResult
$Res call({
 List<Slip> codes, int skip, int limit, int total, bool hasMore
});




}
/// @nodoc
class __$PopularCodesPageCopyWithImpl<$Res>
    implements _$PopularCodesPageCopyWith<$Res> {
  __$PopularCodesPageCopyWithImpl(this._self, this._then);

  final _PopularCodesPage _self;
  final $Res Function(_PopularCodesPage) _then;

/// Create a copy of PopularCodesPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? codes = null,Object? skip = null,Object? limit = null,Object? total = null,Object? hasMore = null,}) {
  return _then(_PopularCodesPage(
codes: null == codes ? _self._codes : codes // ignore: cast_nullable_to_non_nullable
as List<Slip>,skip: null == skip ? _self.skip : skip // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
