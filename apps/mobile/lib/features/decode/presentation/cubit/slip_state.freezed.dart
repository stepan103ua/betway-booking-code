// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slip_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SlipState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlipState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SlipState()';
}


}

/// @nodoc
class $SlipStateCopyWith<$Res>  {
$SlipStateCopyWith(SlipState _, $Res Function(SlipState) __);
}


/// Adds pattern-matching-related methods to [SlipState].
extension SlipStatePatterns on SlipState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SlipInitial value)?  initial,TResult Function( SlipLoading value)?  loading,TResult Function( SlipLoaded value)?  loaded,TResult Function( SlipError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SlipInitial() when initial != null:
return initial(_that);case SlipLoading() when loading != null:
return loading(_that);case SlipLoaded() when loaded != null:
return loaded(_that);case SlipError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SlipInitial value)  initial,required TResult Function( SlipLoading value)  loading,required TResult Function( SlipLoaded value)  loaded,required TResult Function( SlipError value)  error,}){
final _that = this;
switch (_that) {
case SlipInitial():
return initial(_that);case SlipLoading():
return loading(_that);case SlipLoaded():
return loaded(_that);case SlipError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SlipInitial value)?  initial,TResult? Function( SlipLoading value)?  loading,TResult? Function( SlipLoaded value)?  loaded,TResult? Function( SlipError value)?  error,}){
final _that = this;
switch (_that) {
case SlipInitial() when initial != null:
return initial(_that);case SlipLoading() when loading != null:
return loading(_that);case SlipLoaded() when loaded != null:
return loaded(_that);case SlipError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Slip slip)?  loaded,TResult Function( Failure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SlipInitial() when initial != null:
return initial();case SlipLoading() when loading != null:
return loading();case SlipLoaded() when loaded != null:
return loaded(_that.slip);case SlipError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Slip slip)  loaded,required TResult Function( Failure failure)  error,}) {final _that = this;
switch (_that) {
case SlipInitial():
return initial();case SlipLoading():
return loading();case SlipLoaded():
return loaded(_that.slip);case SlipError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Slip slip)?  loaded,TResult? Function( Failure failure)?  error,}) {final _that = this;
switch (_that) {
case SlipInitial() when initial != null:
return initial();case SlipLoading() when loading != null:
return loading();case SlipLoaded() when loaded != null:
return loaded(_that.slip);case SlipError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class SlipInitial implements SlipState {
  const SlipInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlipInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SlipState.initial()';
}


}




/// @nodoc


class SlipLoading implements SlipState {
  const SlipLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlipLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SlipState.loading()';
}


}




/// @nodoc


class SlipLoaded implements SlipState {
  const SlipLoaded(this.slip);
  

 final  Slip slip;

/// Create a copy of SlipState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlipLoadedCopyWith<SlipLoaded> get copyWith => _$SlipLoadedCopyWithImpl<SlipLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlipLoaded&&(identical(other.slip, slip) || other.slip == slip));
}


@override
int get hashCode => Object.hash(runtimeType,slip);

@override
String toString() {
  return 'SlipState.loaded(slip: $slip)';
}


}

/// @nodoc
abstract mixin class $SlipLoadedCopyWith<$Res> implements $SlipStateCopyWith<$Res> {
  factory $SlipLoadedCopyWith(SlipLoaded value, $Res Function(SlipLoaded) _then) = _$SlipLoadedCopyWithImpl;
@useResult
$Res call({
 Slip slip
});


$SlipCopyWith<$Res> get slip;

}
/// @nodoc
class _$SlipLoadedCopyWithImpl<$Res>
    implements $SlipLoadedCopyWith<$Res> {
  _$SlipLoadedCopyWithImpl(this._self, this._then);

  final SlipLoaded _self;
  final $Res Function(SlipLoaded) _then;

/// Create a copy of SlipState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? slip = null,}) {
  return _then(SlipLoaded(
null == slip ? _self.slip : slip // ignore: cast_nullable_to_non_nullable
as Slip,
  ));
}

/// Create a copy of SlipState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlipCopyWith<$Res> get slip {
  
  return $SlipCopyWith<$Res>(_self.slip, (value) {
    return _then(_self.copyWith(slip: value));
  });
}
}

/// @nodoc


class SlipError implements SlipState {
  const SlipError(this.failure);
  

 final  Failure failure;

/// Create a copy of SlipState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlipErrorCopyWith<SlipError> get copyWith => _$SlipErrorCopyWithImpl<SlipError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlipError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'SlipState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SlipErrorCopyWith<$Res> implements $SlipStateCopyWith<$Res> {
  factory $SlipErrorCopyWith(SlipError value, $Res Function(SlipError) _then) = _$SlipErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$SlipErrorCopyWithImpl<$Res>
    implements $SlipErrorCopyWith<$Res> {
  _$SlipErrorCopyWithImpl(this._self, this._then);

  final SlipError _self;
  final $Res Function(SlipError) _then;

/// Create a copy of SlipState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(SlipError(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
