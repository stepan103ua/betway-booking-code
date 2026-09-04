// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_markets_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventMarketsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventMarketsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EventMarketsState()';
}


}

/// @nodoc
class $EventMarketsStateCopyWith<$Res>  {
$EventMarketsStateCopyWith(EventMarketsState _, $Res Function(EventMarketsState) __);
}


/// Adds pattern-matching-related methods to [EventMarketsState].
extension EventMarketsStatePatterns on EventMarketsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EventMarketsLoading value)?  loading,TResult Function( EventMarketsLoaded value)?  loaded,TResult Function( EventMarketsEmpty value)?  empty,TResult Function( EventMarketsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EventMarketsLoading() when loading != null:
return loading(_that);case EventMarketsLoaded() when loaded != null:
return loaded(_that);case EventMarketsEmpty() when empty != null:
return empty(_that);case EventMarketsError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EventMarketsLoading value)  loading,required TResult Function( EventMarketsLoaded value)  loaded,required TResult Function( EventMarketsEmpty value)  empty,required TResult Function( EventMarketsError value)  error,}){
final _that = this;
switch (_that) {
case EventMarketsLoading():
return loading(_that);case EventMarketsLoaded():
return loaded(_that);case EventMarketsEmpty():
return empty(_that);case EventMarketsError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EventMarketsLoading value)?  loading,TResult? Function( EventMarketsLoaded value)?  loaded,TResult? Function( EventMarketsEmpty value)?  empty,TResult? Function( EventMarketsError value)?  error,}){
final _that = this;
switch (_that) {
case EventMarketsLoading() when loading != null:
return loading(_that);case EventMarketsLoaded() when loaded != null:
return loaded(_that);case EventMarketsEmpty() when empty != null:
return empty(_that);case EventMarketsError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<Market> markets)?  loaded,TResult Function()?  empty,TResult Function( Failure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EventMarketsLoading() when loading != null:
return loading();case EventMarketsLoaded() when loaded != null:
return loaded(_that.markets);case EventMarketsEmpty() when empty != null:
return empty();case EventMarketsError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<Market> markets)  loaded,required TResult Function()  empty,required TResult Function( Failure failure)  error,}) {final _that = this;
switch (_that) {
case EventMarketsLoading():
return loading();case EventMarketsLoaded():
return loaded(_that.markets);case EventMarketsEmpty():
return empty();case EventMarketsError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<Market> markets)?  loaded,TResult? Function()?  empty,TResult? Function( Failure failure)?  error,}) {final _that = this;
switch (_that) {
case EventMarketsLoading() when loading != null:
return loading();case EventMarketsLoaded() when loaded != null:
return loaded(_that.markets);case EventMarketsEmpty() when empty != null:
return empty();case EventMarketsError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class EventMarketsLoading implements EventMarketsState {
  const EventMarketsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventMarketsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EventMarketsState.loading()';
}


}




/// @nodoc


class EventMarketsLoaded implements EventMarketsState {
  const EventMarketsLoaded(final  List<Market> markets): _markets = markets;
  

 final  List<Market> _markets;
 List<Market> get markets {
  if (_markets is EqualUnmodifiableListView) return _markets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_markets);
}


/// Create a copy of EventMarketsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventMarketsLoadedCopyWith<EventMarketsLoaded> get copyWith => _$EventMarketsLoadedCopyWithImpl<EventMarketsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventMarketsLoaded&&const DeepCollectionEquality().equals(other._markets, _markets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_markets));

@override
String toString() {
  return 'EventMarketsState.loaded(markets: $markets)';
}


}

/// @nodoc
abstract mixin class $EventMarketsLoadedCopyWith<$Res> implements $EventMarketsStateCopyWith<$Res> {
  factory $EventMarketsLoadedCopyWith(EventMarketsLoaded value, $Res Function(EventMarketsLoaded) _then) = _$EventMarketsLoadedCopyWithImpl;
@useResult
$Res call({
 List<Market> markets
});




}
/// @nodoc
class _$EventMarketsLoadedCopyWithImpl<$Res>
    implements $EventMarketsLoadedCopyWith<$Res> {
  _$EventMarketsLoadedCopyWithImpl(this._self, this._then);

  final EventMarketsLoaded _self;
  final $Res Function(EventMarketsLoaded) _then;

/// Create a copy of EventMarketsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? markets = null,}) {
  return _then(EventMarketsLoaded(
null == markets ? _self._markets : markets // ignore: cast_nullable_to_non_nullable
as List<Market>,
  ));
}


}

/// @nodoc


class EventMarketsEmpty implements EventMarketsState {
  const EventMarketsEmpty();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventMarketsEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EventMarketsState.empty()';
}


}




/// @nodoc


class EventMarketsError implements EventMarketsState {
  const EventMarketsError(this.failure);
  

 final  Failure failure;

/// Create a copy of EventMarketsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventMarketsErrorCopyWith<EventMarketsError> get copyWith => _$EventMarketsErrorCopyWithImpl<EventMarketsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventMarketsError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'EventMarketsState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $EventMarketsErrorCopyWith<$Res> implements $EventMarketsStateCopyWith<$Res> {
  factory $EventMarketsErrorCopyWith(EventMarketsError value, $Res Function(EventMarketsError) _then) = _$EventMarketsErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$EventMarketsErrorCopyWithImpl<$Res>
    implements $EventMarketsErrorCopyWith<$Res> {
  _$EventMarketsErrorCopyWithImpl(this._self, this._then);

  final EventMarketsError _self;
  final $Res Function(EventMarketsError) _then;

/// Create a copy of EventMarketsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(EventMarketsError(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
