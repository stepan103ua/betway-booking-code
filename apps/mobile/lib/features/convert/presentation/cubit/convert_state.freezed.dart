// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'convert_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConvertState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConvertState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConvertState()';
}


}

/// @nodoc
class $ConvertStateCopyWith<$Res>  {
$ConvertStateCopyWith(ConvertState _, $Res Function(ConvertState) __);
}


/// Adds pattern-matching-related methods to [ConvertState].
extension ConvertStatePatterns on ConvertState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ConvertInitial value)?  initial,TResult Function( ConvertResolving value)?  resolving,TResult Function( ConvertReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ConvertInitial() when initial != null:
return initial(_that);case ConvertResolving() when resolving != null:
return resolving(_that);case ConvertReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ConvertInitial value)  initial,required TResult Function( ConvertResolving value)  resolving,required TResult Function( ConvertReady value)  ready,}){
final _that = this;
switch (_that) {
case ConvertInitial():
return initial(_that);case ConvertResolving():
return resolving(_that);case ConvertReady():
return ready(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ConvertInitial value)?  initial,TResult? Function( ConvertResolving value)?  resolving,TResult? Function( ConvertReady value)?  ready,}){
final _that = this;
switch (_that) {
case ConvertInitial() when initial != null:
return initial(_that);case ConvertResolving() when resolving != null:
return resolving(_that);case ConvertReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Failure? codeError)?  initial,TResult Function()?  resolving,TResult Function( Slip original,  Set<String> dropOutcomeIds,  bool converting,  Failure? convertError,  ConvertResult? result)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ConvertInitial() when initial != null:
return initial(_that.codeError);case ConvertResolving() when resolving != null:
return resolving();case ConvertReady() when ready != null:
return ready(_that.original,_that.dropOutcomeIds,_that.converting,_that.convertError,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Failure? codeError)  initial,required TResult Function()  resolving,required TResult Function( Slip original,  Set<String> dropOutcomeIds,  bool converting,  Failure? convertError,  ConvertResult? result)  ready,}) {final _that = this;
switch (_that) {
case ConvertInitial():
return initial(_that.codeError);case ConvertResolving():
return resolving();case ConvertReady():
return ready(_that.original,_that.dropOutcomeIds,_that.converting,_that.convertError,_that.result);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Failure? codeError)?  initial,TResult? Function()?  resolving,TResult? Function( Slip original,  Set<String> dropOutcomeIds,  bool converting,  Failure? convertError,  ConvertResult? result)?  ready,}) {final _that = this;
switch (_that) {
case ConvertInitial() when initial != null:
return initial(_that.codeError);case ConvertResolving() when resolving != null:
return resolving();case ConvertReady() when ready != null:
return ready(_that.original,_that.dropOutcomeIds,_that.converting,_that.convertError,_that.result);case _:
  return null;

}
}

}

/// @nodoc


class ConvertInitial implements ConvertState {
  const ConvertInitial({this.codeError});
  

 final  Failure? codeError;

/// Create a copy of ConvertState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConvertInitialCopyWith<ConvertInitial> get copyWith => _$ConvertInitialCopyWithImpl<ConvertInitial>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConvertInitial&&(identical(other.codeError, codeError) || other.codeError == codeError));
}


@override
int get hashCode => Object.hash(runtimeType,codeError);

@override
String toString() {
  return 'ConvertState.initial(codeError: $codeError)';
}


}

/// @nodoc
abstract mixin class $ConvertInitialCopyWith<$Res> implements $ConvertStateCopyWith<$Res> {
  factory $ConvertInitialCopyWith(ConvertInitial value, $Res Function(ConvertInitial) _then) = _$ConvertInitialCopyWithImpl;
@useResult
$Res call({
 Failure? codeError
});




}
/// @nodoc
class _$ConvertInitialCopyWithImpl<$Res>
    implements $ConvertInitialCopyWith<$Res> {
  _$ConvertInitialCopyWithImpl(this._self, this._then);

  final ConvertInitial _self;
  final $Res Function(ConvertInitial) _then;

/// Create a copy of ConvertState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? codeError = freezed,}) {
  return _then(ConvertInitial(
codeError: freezed == codeError ? _self.codeError : codeError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

/// @nodoc


class ConvertResolving implements ConvertState {
  const ConvertResolving();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConvertResolving);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConvertState.resolving()';
}


}




/// @nodoc


class ConvertReady implements ConvertState {
  const ConvertReady({required this.original, final  Set<String> dropOutcomeIds = const <String>{}, this.converting = false, this.convertError, this.result}): _dropOutcomeIds = dropOutcomeIds;
  

 final  Slip original;
 final  Set<String> _dropOutcomeIds;
@JsonKey() Set<String> get dropOutcomeIds {
  if (_dropOutcomeIds is EqualUnmodifiableSetView) return _dropOutcomeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_dropOutcomeIds);
}

@JsonKey() final  bool converting;
 final  Failure? convertError;
 final  ConvertResult? result;

/// Create a copy of ConvertState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConvertReadyCopyWith<ConvertReady> get copyWith => _$ConvertReadyCopyWithImpl<ConvertReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConvertReady&&(identical(other.original, original) || other.original == original)&&const DeepCollectionEquality().equals(other._dropOutcomeIds, _dropOutcomeIds)&&(identical(other.converting, converting) || other.converting == converting)&&(identical(other.convertError, convertError) || other.convertError == convertError)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,original,const DeepCollectionEquality().hash(_dropOutcomeIds),converting,convertError,result);

@override
String toString() {
  return 'ConvertState.ready(original: $original, dropOutcomeIds: $dropOutcomeIds, converting: $converting, convertError: $convertError, result: $result)';
}


}

/// @nodoc
abstract mixin class $ConvertReadyCopyWith<$Res> implements $ConvertStateCopyWith<$Res> {
  factory $ConvertReadyCopyWith(ConvertReady value, $Res Function(ConvertReady) _then) = _$ConvertReadyCopyWithImpl;
@useResult
$Res call({
 Slip original, Set<String> dropOutcomeIds, bool converting, Failure? convertError, ConvertResult? result
});


$SlipCopyWith<$Res> get original;$ConvertResultCopyWith<$Res>? get result;

}
/// @nodoc
class _$ConvertReadyCopyWithImpl<$Res>
    implements $ConvertReadyCopyWith<$Res> {
  _$ConvertReadyCopyWithImpl(this._self, this._then);

  final ConvertReady _self;
  final $Res Function(ConvertReady) _then;

/// Create a copy of ConvertState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? original = null,Object? dropOutcomeIds = null,Object? converting = null,Object? convertError = freezed,Object? result = freezed,}) {
  return _then(ConvertReady(
original: null == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Slip,dropOutcomeIds: null == dropOutcomeIds ? _self._dropOutcomeIds : dropOutcomeIds // ignore: cast_nullable_to_non_nullable
as Set<String>,converting: null == converting ? _self.converting : converting // ignore: cast_nullable_to_non_nullable
as bool,convertError: freezed == convertError ? _self.convertError : convertError // ignore: cast_nullable_to_non_nullable
as Failure?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ConvertResult?,
  ));
}

/// Create a copy of ConvertState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlipCopyWith<$Res> get original {
  
  return $SlipCopyWith<$Res>(_self.original, (value) {
    return _then(_self.copyWith(original: value));
  });
}/// Create a copy of ConvertState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConvertResultCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $ConvertResultCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

// dart format on
