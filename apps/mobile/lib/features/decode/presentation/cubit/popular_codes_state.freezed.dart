// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'popular_codes_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PopularCodesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PopularCodesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PopularCodesState()';
}


}

/// @nodoc
class $PopularCodesStateCopyWith<$Res>  {
$PopularCodesStateCopyWith(PopularCodesState _, $Res Function(PopularCodesState) __);
}


/// Adds pattern-matching-related methods to [PopularCodesState].
extension PopularCodesStatePatterns on PopularCodesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PopularCodesLoading value)?  loading,TResult Function( PopularCodesLoaded value)?  loaded,TResult Function( PopularCodesError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PopularCodesLoading() when loading != null:
return loading(_that);case PopularCodesLoaded() when loaded != null:
return loaded(_that);case PopularCodesError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PopularCodesLoading value)  loading,required TResult Function( PopularCodesLoaded value)  loaded,required TResult Function( PopularCodesError value)  error,}){
final _that = this;
switch (_that) {
case PopularCodesLoading():
return loading(_that);case PopularCodesLoaded():
return loaded(_that);case PopularCodesError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PopularCodesLoading value)?  loading,TResult? Function( PopularCodesLoaded value)?  loaded,TResult? Function( PopularCodesError value)?  error,}){
final _that = this;
switch (_that) {
case PopularCodesLoading() when loading != null:
return loading(_that);case PopularCodesLoaded() when loaded != null:
return loaded(_that);case PopularCodesError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<Slip> codes,  int total,  bool hasMore,  int nextSkip,  bool loadingMore,  Failure? loadMoreError)?  loaded,TResult Function( Failure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PopularCodesLoading() when loading != null:
return loading();case PopularCodesLoaded() when loaded != null:
return loaded(_that.codes,_that.total,_that.hasMore,_that.nextSkip,_that.loadingMore,_that.loadMoreError);case PopularCodesError() when error != null:
return error(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<Slip> codes,  int total,  bool hasMore,  int nextSkip,  bool loadingMore,  Failure? loadMoreError)  loaded,required TResult Function( Failure failure)  error,}) {final _that = this;
switch (_that) {
case PopularCodesLoading():
return loading();case PopularCodesLoaded():
return loaded(_that.codes,_that.total,_that.hasMore,_that.nextSkip,_that.loadingMore,_that.loadMoreError);case PopularCodesError():
return error(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<Slip> codes,  int total,  bool hasMore,  int nextSkip,  bool loadingMore,  Failure? loadMoreError)?  loaded,TResult? Function( Failure failure)?  error,}) {final _that = this;
switch (_that) {
case PopularCodesLoading() when loading != null:
return loading();case PopularCodesLoaded() when loaded != null:
return loaded(_that.codes,_that.total,_that.hasMore,_that.nextSkip,_that.loadingMore,_that.loadMoreError);case PopularCodesError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class PopularCodesLoading implements PopularCodesState {
  const PopularCodesLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PopularCodesLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PopularCodesState.loading()';
}


}




/// @nodoc


class PopularCodesLoaded implements PopularCodesState {
  const PopularCodesLoaded({required final  List<Slip> codes, required this.total, required this.hasMore, required this.nextSkip, this.loadingMore = false, this.loadMoreError}): _codes = codes;
  

 final  List<Slip> _codes;
 List<Slip> get codes {
  if (_codes is EqualUnmodifiableListView) return _codes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_codes);
}

 final  int total;
 final  bool hasMore;
 final  int nextSkip;
@JsonKey() final  bool loadingMore;
 final  Failure? loadMoreError;

/// Create a copy of PopularCodesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PopularCodesLoadedCopyWith<PopularCodesLoaded> get copyWith => _$PopularCodesLoadedCopyWithImpl<PopularCodesLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PopularCodesLoaded&&const DeepCollectionEquality().equals(other._codes, _codes)&&(identical(other.total, total) || other.total == total)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextSkip, nextSkip) || other.nextSkip == nextSkip)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&(identical(other.loadMoreError, loadMoreError) || other.loadMoreError == loadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_codes),total,hasMore,nextSkip,loadingMore,loadMoreError);

@override
String toString() {
  return 'PopularCodesState.loaded(codes: $codes, total: $total, hasMore: $hasMore, nextSkip: $nextSkip, loadingMore: $loadingMore, loadMoreError: $loadMoreError)';
}


}

/// @nodoc
abstract mixin class $PopularCodesLoadedCopyWith<$Res> implements $PopularCodesStateCopyWith<$Res> {
  factory $PopularCodesLoadedCopyWith(PopularCodesLoaded value, $Res Function(PopularCodesLoaded) _then) = _$PopularCodesLoadedCopyWithImpl;
@useResult
$Res call({
 List<Slip> codes, int total, bool hasMore, int nextSkip, bool loadingMore, Failure? loadMoreError
});




}
/// @nodoc
class _$PopularCodesLoadedCopyWithImpl<$Res>
    implements $PopularCodesLoadedCopyWith<$Res> {
  _$PopularCodesLoadedCopyWithImpl(this._self, this._then);

  final PopularCodesLoaded _self;
  final $Res Function(PopularCodesLoaded) _then;

/// Create a copy of PopularCodesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? codes = null,Object? total = null,Object? hasMore = null,Object? nextSkip = null,Object? loadingMore = null,Object? loadMoreError = freezed,}) {
  return _then(PopularCodesLoaded(
codes: null == codes ? _self._codes : codes // ignore: cast_nullable_to_non_nullable
as List<Slip>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextSkip: null == nextSkip ? _self.nextSkip : nextSkip // ignore: cast_nullable_to_non_nullable
as int,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

/// @nodoc


class PopularCodesError implements PopularCodesState {
  const PopularCodesError(this.failure);
  

 final  Failure failure;

/// Create a copy of PopularCodesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PopularCodesErrorCopyWith<PopularCodesError> get copyWith => _$PopularCodesErrorCopyWithImpl<PopularCodesError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PopularCodesError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'PopularCodesState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $PopularCodesErrorCopyWith<$Res> implements $PopularCodesStateCopyWith<$Res> {
  factory $PopularCodesErrorCopyWith(PopularCodesError value, $Res Function(PopularCodesError) _then) = _$PopularCodesErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$PopularCodesErrorCopyWithImpl<$Res>
    implements $PopularCodesErrorCopyWith<$Res> {
  _$PopularCodesErrorCopyWithImpl(this._self, this._then);

  final PopularCodesError _self;
  final $Res Function(PopularCodesError) _then;

/// Create a copy of PopularCodesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(PopularCodesError(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
