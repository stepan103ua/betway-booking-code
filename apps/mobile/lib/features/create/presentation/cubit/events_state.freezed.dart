// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'events_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EventsState()';
}


}

/// @nodoc
class $EventsStateCopyWith<$Res>  {
$EventsStateCopyWith(EventsState _, $Res Function(EventsState) __);
}


/// Adds pattern-matching-related methods to [EventsState].
extension EventsStatePatterns on EventsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EventsLoading value)?  loading,TResult Function( EventsLoaded value)?  loaded,TResult Function( EventsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EventsLoading() when loading != null:
return loading(_that);case EventsLoaded() when loaded != null:
return loaded(_that);case EventsError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EventsLoading value)  loading,required TResult Function( EventsLoaded value)  loaded,required TResult Function( EventsError value)  error,}){
final _that = this;
switch (_that) {
case EventsLoading():
return loading(_that);case EventsLoaded():
return loaded(_that);case EventsError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EventsLoading value)?  loading,TResult? Function( EventsLoaded value)?  loaded,TResult? Function( EventsError value)?  error,}){
final _that = this;
switch (_that) {
case EventsLoading() when loading != null:
return loading(_that);case EventsLoaded() when loaded != null:
return loaded(_that);case EventsError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<Fixture> events,  bool hasMore,  int nextSkip,  bool loadingMore,  Failure? loadMoreError)?  loaded,TResult Function( Failure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EventsLoading() when loading != null:
return loading();case EventsLoaded() when loaded != null:
return loaded(_that.events,_that.hasMore,_that.nextSkip,_that.loadingMore,_that.loadMoreError);case EventsError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<Fixture> events,  bool hasMore,  int nextSkip,  bool loadingMore,  Failure? loadMoreError)  loaded,required TResult Function( Failure failure)  error,}) {final _that = this;
switch (_that) {
case EventsLoading():
return loading();case EventsLoaded():
return loaded(_that.events,_that.hasMore,_that.nextSkip,_that.loadingMore,_that.loadMoreError);case EventsError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<Fixture> events,  bool hasMore,  int nextSkip,  bool loadingMore,  Failure? loadMoreError)?  loaded,TResult? Function( Failure failure)?  error,}) {final _that = this;
switch (_that) {
case EventsLoading() when loading != null:
return loading();case EventsLoaded() when loaded != null:
return loaded(_that.events,_that.hasMore,_that.nextSkip,_that.loadingMore,_that.loadMoreError);case EventsError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class EventsLoading implements EventsState {
  const EventsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EventsState.loading()';
}


}




/// @nodoc


class EventsLoaded implements EventsState {
  const EventsLoaded({required final  List<Fixture> events, required this.hasMore, required this.nextSkip, this.loadingMore = false, this.loadMoreError}): _events = events;
  

 final  List<Fixture> _events;
 List<Fixture> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

 final  bool hasMore;
 final  int nextSkip;
@JsonKey() final  bool loadingMore;
 final  Failure? loadMoreError;

/// Create a copy of EventsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventsLoadedCopyWith<EventsLoaded> get copyWith => _$EventsLoadedCopyWithImpl<EventsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventsLoaded&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextSkip, nextSkip) || other.nextSkip == nextSkip)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&(identical(other.loadMoreError, loadMoreError) || other.loadMoreError == loadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_events),hasMore,nextSkip,loadingMore,loadMoreError);

@override
String toString() {
  return 'EventsState.loaded(events: $events, hasMore: $hasMore, nextSkip: $nextSkip, loadingMore: $loadingMore, loadMoreError: $loadMoreError)';
}


}

/// @nodoc
abstract mixin class $EventsLoadedCopyWith<$Res> implements $EventsStateCopyWith<$Res> {
  factory $EventsLoadedCopyWith(EventsLoaded value, $Res Function(EventsLoaded) _then) = _$EventsLoadedCopyWithImpl;
@useResult
$Res call({
 List<Fixture> events, bool hasMore, int nextSkip, bool loadingMore, Failure? loadMoreError
});




}
/// @nodoc
class _$EventsLoadedCopyWithImpl<$Res>
    implements $EventsLoadedCopyWith<$Res> {
  _$EventsLoadedCopyWithImpl(this._self, this._then);

  final EventsLoaded _self;
  final $Res Function(EventsLoaded) _then;

/// Create a copy of EventsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? events = null,Object? hasMore = null,Object? nextSkip = null,Object? loadingMore = null,Object? loadMoreError = freezed,}) {
  return _then(EventsLoaded(
events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<Fixture>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextSkip: null == nextSkip ? _self.nextSkip : nextSkip // ignore: cast_nullable_to_non_nullable
as int,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

/// @nodoc


class EventsError implements EventsState {
  const EventsError(this.failure);
  

 final  Failure failure;

/// Create a copy of EventsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventsErrorCopyWith<EventsError> get copyWith => _$EventsErrorCopyWithImpl<EventsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventsError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'EventsState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $EventsErrorCopyWith<$Res> implements $EventsStateCopyWith<$Res> {
  factory $EventsErrorCopyWith(EventsError value, $Res Function(EventsError) _then) = _$EventsErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$EventsErrorCopyWithImpl<$Res>
    implements $EventsErrorCopyWith<$Res> {
  _$EventsErrorCopyWithImpl(this._self, this._then);

  final EventsError _self;
  final $Res Function(EventsError) _then;

/// Create a copy of EventsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(EventsError(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
