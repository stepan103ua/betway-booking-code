// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'events_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventsPage {

 List<Fixture> get events; int get skip; int get limit; bool get hasMore;
/// Create a copy of EventsPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventsPageCopyWith<EventsPage> get copyWith => _$EventsPageCopyWithImpl<EventsPage>(this as EventsPage, _$identity);

  /// Serializes this EventsPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventsPage&&const DeepCollectionEquality().equals(other.events, events)&&(identical(other.skip, skip) || other.skip == skip)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(events),skip,limit,hasMore);

@override
String toString() {
  return 'EventsPage(events: $events, skip: $skip, limit: $limit, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $EventsPageCopyWith<$Res>  {
  factory $EventsPageCopyWith(EventsPage value, $Res Function(EventsPage) _then) = _$EventsPageCopyWithImpl;
@useResult
$Res call({
 List<Fixture> events, int skip, int limit, bool hasMore
});




}
/// @nodoc
class _$EventsPageCopyWithImpl<$Res>
    implements $EventsPageCopyWith<$Res> {
  _$EventsPageCopyWithImpl(this._self, this._then);

  final EventsPage _self;
  final $Res Function(EventsPage) _then;

/// Create a copy of EventsPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? events = null,Object? skip = null,Object? limit = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<Fixture>,skip: null == skip ? _self.skip : skip // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EventsPage].
extension EventsPagePatterns on EventsPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventsPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventsPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventsPage value)  $default,){
final _that = this;
switch (_that) {
case _EventsPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventsPage value)?  $default,){
final _that = this;
switch (_that) {
case _EventsPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Fixture> events,  int skip,  int limit,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventsPage() when $default != null:
return $default(_that.events,_that.skip,_that.limit,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Fixture> events,  int skip,  int limit,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _EventsPage():
return $default(_that.events,_that.skip,_that.limit,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Fixture> events,  int skip,  int limit,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _EventsPage() when $default != null:
return $default(_that.events,_that.skip,_that.limit,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventsPage implements EventsPage {
  const _EventsPage({required final  List<Fixture> events, required this.skip, required this.limit, required this.hasMore}): _events = events;
  factory _EventsPage.fromJson(Map<String, dynamic> json) => _$EventsPageFromJson(json);

 final  List<Fixture> _events;
@override List<Fixture> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

@override final  int skip;
@override final  int limit;
@override final  bool hasMore;

/// Create a copy of EventsPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventsPageCopyWith<_EventsPage> get copyWith => __$EventsPageCopyWithImpl<_EventsPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventsPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventsPage&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.skip, skip) || other.skip == skip)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_events),skip,limit,hasMore);

@override
String toString() {
  return 'EventsPage(events: $events, skip: $skip, limit: $limit, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$EventsPageCopyWith<$Res> implements $EventsPageCopyWith<$Res> {
  factory _$EventsPageCopyWith(_EventsPage value, $Res Function(_EventsPage) _then) = __$EventsPageCopyWithImpl;
@override @useResult
$Res call({
 List<Fixture> events, int skip, int limit, bool hasMore
});




}
/// @nodoc
class __$EventsPageCopyWithImpl<$Res>
    implements _$EventsPageCopyWith<$Res> {
  __$EventsPageCopyWithImpl(this._self, this._then);

  final _EventsPage _self;
  final $Res Function(_EventsPage) _then;

/// Create a copy of EventsPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? events = null,Object? skip = null,Object? limit = null,Object? hasMore = null,}) {
  return _then(_EventsPage(
events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<Fixture>,skip: null == skip ? _self.skip : skip // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
