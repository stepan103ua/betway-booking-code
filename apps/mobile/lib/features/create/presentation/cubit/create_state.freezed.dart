// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreateState()';
}


}

/// @nodoc
class $CreateStateCopyWith<$Res>  {
$CreateStateCopyWith(CreateState _, $Res Function(CreateState) __);
}


/// Adds pattern-matching-related methods to [CreateState].
extension CreateStatePatterns on CreateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CreateLoadingSports value)?  loadingSports,TResult Function( CreateSportsError value)?  sportsError,TResult Function( CreateReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CreateLoadingSports() when loadingSports != null:
return loadingSports(_that);case CreateSportsError() when sportsError != null:
return sportsError(_that);case CreateReady() when ready != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CreateLoadingSports value)  loadingSports,required TResult Function( CreateSportsError value)  sportsError,required TResult Function( CreateReady value)  ready,}){
final _that = this;
switch (_that) {
case CreateLoadingSports():
return loadingSports(_that);case CreateSportsError():
return sportsError(_that);case CreateReady():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CreateLoadingSports value)?  loadingSports,TResult? Function( CreateSportsError value)?  sportsError,TResult? Function( CreateReady value)?  ready,}){
final _that = this;
switch (_that) {
case CreateLoadingSports() when loadingSports != null:
return loadingSports(_that);case CreateSportsError() when sportsError != null:
return sportsError(_that);case CreateReady() when ready != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loadingSports,TResult Function( Failure failure)?  sportsError,TResult Function( List<Sport> sports,  Sport selectedSport,  List<DraftPick> picks,  bool generating,  Failure? generateError,  String? createdCode)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CreateLoadingSports() when loadingSports != null:
return loadingSports();case CreateSportsError() when sportsError != null:
return sportsError(_that.failure);case CreateReady() when ready != null:
return ready(_that.sports,_that.selectedSport,_that.picks,_that.generating,_that.generateError,_that.createdCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loadingSports,required TResult Function( Failure failure)  sportsError,required TResult Function( List<Sport> sports,  Sport selectedSport,  List<DraftPick> picks,  bool generating,  Failure? generateError,  String? createdCode)  ready,}) {final _that = this;
switch (_that) {
case CreateLoadingSports():
return loadingSports();case CreateSportsError():
return sportsError(_that.failure);case CreateReady():
return ready(_that.sports,_that.selectedSport,_that.picks,_that.generating,_that.generateError,_that.createdCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loadingSports,TResult? Function( Failure failure)?  sportsError,TResult? Function( List<Sport> sports,  Sport selectedSport,  List<DraftPick> picks,  bool generating,  Failure? generateError,  String? createdCode)?  ready,}) {final _that = this;
switch (_that) {
case CreateLoadingSports() when loadingSports != null:
return loadingSports();case CreateSportsError() when sportsError != null:
return sportsError(_that.failure);case CreateReady() when ready != null:
return ready(_that.sports,_that.selectedSport,_that.picks,_that.generating,_that.generateError,_that.createdCode);case _:
  return null;

}
}

}

/// @nodoc


class CreateLoadingSports implements CreateState {
  const CreateLoadingSports();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateLoadingSports);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreateState.loadingSports()';
}


}




/// @nodoc


class CreateSportsError implements CreateState {
  const CreateSportsError(this.failure);
  

 final  Failure failure;

/// Create a copy of CreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateSportsErrorCopyWith<CreateSportsError> get copyWith => _$CreateSportsErrorCopyWithImpl<CreateSportsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSportsError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'CreateState.sportsError(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $CreateSportsErrorCopyWith<$Res> implements $CreateStateCopyWith<$Res> {
  factory $CreateSportsErrorCopyWith(CreateSportsError value, $Res Function(CreateSportsError) _then) = _$CreateSportsErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$CreateSportsErrorCopyWithImpl<$Res>
    implements $CreateSportsErrorCopyWith<$Res> {
  _$CreateSportsErrorCopyWithImpl(this._self, this._then);

  final CreateSportsError _self;
  final $Res Function(CreateSportsError) _then;

/// Create a copy of CreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(CreateSportsError(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

/// @nodoc


class CreateReady implements CreateState {
  const CreateReady({required final  List<Sport> sports, required this.selectedSport, final  List<DraftPick> picks = const <DraftPick>[], this.generating = false, this.generateError, this.createdCode}): _sports = sports,_picks = picks;
  

 final  List<Sport> _sports;
 List<Sport> get sports {
  if (_sports is EqualUnmodifiableListView) return _sports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sports);
}

 final  Sport selectedSport;
 final  List<DraftPick> _picks;
@JsonKey() List<DraftPick> get picks {
  if (_picks is EqualUnmodifiableListView) return _picks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_picks);
}

@JsonKey() final  bool generating;
 final  Failure? generateError;
 final  String? createdCode;

/// Create a copy of CreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateReadyCopyWith<CreateReady> get copyWith => _$CreateReadyCopyWithImpl<CreateReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateReady&&const DeepCollectionEquality().equals(other._sports, _sports)&&(identical(other.selectedSport, selectedSport) || other.selectedSport == selectedSport)&&const DeepCollectionEquality().equals(other._picks, _picks)&&(identical(other.generating, generating) || other.generating == generating)&&(identical(other.generateError, generateError) || other.generateError == generateError)&&(identical(other.createdCode, createdCode) || other.createdCode == createdCode));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sports),selectedSport,const DeepCollectionEquality().hash(_picks),generating,generateError,createdCode);

@override
String toString() {
  return 'CreateState.ready(sports: $sports, selectedSport: $selectedSport, picks: $picks, generating: $generating, generateError: $generateError, createdCode: $createdCode)';
}


}

/// @nodoc
abstract mixin class $CreateReadyCopyWith<$Res> implements $CreateStateCopyWith<$Res> {
  factory $CreateReadyCopyWith(CreateReady value, $Res Function(CreateReady) _then) = _$CreateReadyCopyWithImpl;
@useResult
$Res call({
 List<Sport> sports, Sport selectedSport, List<DraftPick> picks, bool generating, Failure? generateError, String? createdCode
});


$SportCopyWith<$Res> get selectedSport;

}
/// @nodoc
class _$CreateReadyCopyWithImpl<$Res>
    implements $CreateReadyCopyWith<$Res> {
  _$CreateReadyCopyWithImpl(this._self, this._then);

  final CreateReady _self;
  final $Res Function(CreateReady) _then;

/// Create a copy of CreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sports = null,Object? selectedSport = null,Object? picks = null,Object? generating = null,Object? generateError = freezed,Object? createdCode = freezed,}) {
  return _then(CreateReady(
sports: null == sports ? _self._sports : sports // ignore: cast_nullable_to_non_nullable
as List<Sport>,selectedSport: null == selectedSport ? _self.selectedSport : selectedSport // ignore: cast_nullable_to_non_nullable
as Sport,picks: null == picks ? _self._picks : picks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,generating: null == generating ? _self.generating : generating // ignore: cast_nullable_to_non_nullable
as bool,generateError: freezed == generateError ? _self.generateError : generateError // ignore: cast_nullable_to_non_nullable
as Failure?,createdCode: freezed == createdCode ? _self.createdCode : createdCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SportCopyWith<$Res> get selectedSport {
  
  return $SportCopyWith<$Res>(_self.selectedSport, (value) {
    return _then(_self.copyWith(selectedSport: value));
  });
}
}

// dart format on
