// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fixture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Fixture {

 String get eventId; String get name; String get league; String get kickoffAt; List<Market> get markets;
/// Create a copy of Fixture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FixtureCopyWith<Fixture> get copyWith => _$FixtureCopyWithImpl<Fixture>(this as Fixture, _$identity);

  /// Serializes this Fixture to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Fixture&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.name, name) || other.name == name)&&(identical(other.league, league) || other.league == league)&&(identical(other.kickoffAt, kickoffAt) || other.kickoffAt == kickoffAt)&&const DeepCollectionEquality().equals(other.markets, markets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,name,league,kickoffAt,const DeepCollectionEquality().hash(markets));

@override
String toString() {
  return 'Fixture(eventId: $eventId, name: $name, league: $league, kickoffAt: $kickoffAt, markets: $markets)';
}


}

/// @nodoc
abstract mixin class $FixtureCopyWith<$Res>  {
  factory $FixtureCopyWith(Fixture value, $Res Function(Fixture) _then) = _$FixtureCopyWithImpl;
@useResult
$Res call({
 String eventId, String name, String league, String kickoffAt, List<Market> markets
});




}
/// @nodoc
class _$FixtureCopyWithImpl<$Res>
    implements $FixtureCopyWith<$Res> {
  _$FixtureCopyWithImpl(this._self, this._then);

  final Fixture _self;
  final $Res Function(Fixture) _then;

/// Create a copy of Fixture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? name = null,Object? league = null,Object? kickoffAt = null,Object? markets = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,league: null == league ? _self.league : league // ignore: cast_nullable_to_non_nullable
as String,kickoffAt: null == kickoffAt ? _self.kickoffAt : kickoffAt // ignore: cast_nullable_to_non_nullable
as String,markets: null == markets ? _self.markets : markets // ignore: cast_nullable_to_non_nullable
as List<Market>,
  ));
}

}


/// Adds pattern-matching-related methods to [Fixture].
extension FixturePatterns on Fixture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Fixture value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Fixture() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Fixture value)  $default,){
final _that = this;
switch (_that) {
case _Fixture():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Fixture value)?  $default,){
final _that = this;
switch (_that) {
case _Fixture() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  String name,  String league,  String kickoffAt,  List<Market> markets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Fixture() when $default != null:
return $default(_that.eventId,_that.name,_that.league,_that.kickoffAt,_that.markets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  String name,  String league,  String kickoffAt,  List<Market> markets)  $default,) {final _that = this;
switch (_that) {
case _Fixture():
return $default(_that.eventId,_that.name,_that.league,_that.kickoffAt,_that.markets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  String name,  String league,  String kickoffAt,  List<Market> markets)?  $default,) {final _that = this;
switch (_that) {
case _Fixture() when $default != null:
return $default(_that.eventId,_that.name,_that.league,_that.kickoffAt,_that.markets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Fixture implements Fixture {
  const _Fixture({required this.eventId, required this.name, required this.league, required this.kickoffAt, required final  List<Market> markets}): _markets = markets;
  factory _Fixture.fromJson(Map<String, dynamic> json) => _$FixtureFromJson(json);

@override final  String eventId;
@override final  String name;
@override final  String league;
@override final  String kickoffAt;
 final  List<Market> _markets;
@override List<Market> get markets {
  if (_markets is EqualUnmodifiableListView) return _markets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_markets);
}


/// Create a copy of Fixture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FixtureCopyWith<_Fixture> get copyWith => __$FixtureCopyWithImpl<_Fixture>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FixtureToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Fixture&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.name, name) || other.name == name)&&(identical(other.league, league) || other.league == league)&&(identical(other.kickoffAt, kickoffAt) || other.kickoffAt == kickoffAt)&&const DeepCollectionEquality().equals(other._markets, _markets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,name,league,kickoffAt,const DeepCollectionEquality().hash(_markets));

@override
String toString() {
  return 'Fixture(eventId: $eventId, name: $name, league: $league, kickoffAt: $kickoffAt, markets: $markets)';
}


}

/// @nodoc
abstract mixin class _$FixtureCopyWith<$Res> implements $FixtureCopyWith<$Res> {
  factory _$FixtureCopyWith(_Fixture value, $Res Function(_Fixture) _then) = __$FixtureCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String name, String league, String kickoffAt, List<Market> markets
});




}
/// @nodoc
class __$FixtureCopyWithImpl<$Res>
    implements _$FixtureCopyWith<$Res> {
  __$FixtureCopyWithImpl(this._self, this._then);

  final _Fixture _self;
  final $Res Function(_Fixture) _then;

/// Create a copy of Fixture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? name = null,Object? league = null,Object? kickoffAt = null,Object? markets = null,}) {
  return _then(_Fixture(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,league: null == league ? _self.league : league // ignore: cast_nullable_to_non_nullable
as String,kickoffAt: null == kickoffAt ? _self.kickoffAt : kickoffAt // ignore: cast_nullable_to_non_nullable
as String,markets: null == markets ? _self._markets : markets // ignore: cast_nullable_to_non_nullable
as List<Market>,
  ));
}


}


/// @nodoc
mixin _$Market {

 String get marketId;/// Display-ready and fully qualified: `"1X2"`, `"Total (6.5)"`.
 String get name;/// Stable machine key — branch on this, never on `name` or the numeric
/// part of an id. Not unique within an event (`docs/backend-api.md` §0).
 String get type; List<MarketOutcome> get outcomes;
/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketCopyWith<Market> get copyWith => _$MarketCopyWithImpl<Market>(this as Market, _$identity);

  /// Serializes this Market to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Market&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.outcomes, outcomes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,marketId,name,type,const DeepCollectionEquality().hash(outcomes));

@override
String toString() {
  return 'Market(marketId: $marketId, name: $name, type: $type, outcomes: $outcomes)';
}


}

/// @nodoc
abstract mixin class $MarketCopyWith<$Res>  {
  factory $MarketCopyWith(Market value, $Res Function(Market) _then) = _$MarketCopyWithImpl;
@useResult
$Res call({
 String marketId, String name, String type, List<MarketOutcome> outcomes
});




}
/// @nodoc
class _$MarketCopyWithImpl<$Res>
    implements $MarketCopyWith<$Res> {
  _$MarketCopyWithImpl(this._self, this._then);

  final Market _self;
  final $Res Function(Market) _then;

/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? marketId = null,Object? name = null,Object? type = null,Object? outcomes = null,}) {
  return _then(_self.copyWith(
marketId: null == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,outcomes: null == outcomes ? _self.outcomes : outcomes // ignore: cast_nullable_to_non_nullable
as List<MarketOutcome>,
  ));
}

}


/// Adds pattern-matching-related methods to [Market].
extension MarketPatterns on Market {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Market value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Market() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Market value)  $default,){
final _that = this;
switch (_that) {
case _Market():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Market value)?  $default,){
final _that = this;
switch (_that) {
case _Market() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String marketId,  String name,  String type,  List<MarketOutcome> outcomes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Market() when $default != null:
return $default(_that.marketId,_that.name,_that.type,_that.outcomes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String marketId,  String name,  String type,  List<MarketOutcome> outcomes)  $default,) {final _that = this;
switch (_that) {
case _Market():
return $default(_that.marketId,_that.name,_that.type,_that.outcomes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String marketId,  String name,  String type,  List<MarketOutcome> outcomes)?  $default,) {final _that = this;
switch (_that) {
case _Market() when $default != null:
return $default(_that.marketId,_that.name,_that.type,_that.outcomes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Market implements Market {
  const _Market({required this.marketId, required this.name, required this.type, required final  List<MarketOutcome> outcomes}): _outcomes = outcomes;
  factory _Market.fromJson(Map<String, dynamic> json) => _$MarketFromJson(json);

@override final  String marketId;
/// Display-ready and fully qualified: `"1X2"`, `"Total (6.5)"`.
@override final  String name;
/// Stable machine key — branch on this, never on `name` or the numeric
/// part of an id. Not unique within an event (`docs/backend-api.md` §0).
@override final  String type;
 final  List<MarketOutcome> _outcomes;
@override List<MarketOutcome> get outcomes {
  if (_outcomes is EqualUnmodifiableListView) return _outcomes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_outcomes);
}


/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketCopyWith<_Market> get copyWith => __$MarketCopyWithImpl<_Market>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Market&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._outcomes, _outcomes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,marketId,name,type,const DeepCollectionEquality().hash(_outcomes));

@override
String toString() {
  return 'Market(marketId: $marketId, name: $name, type: $type, outcomes: $outcomes)';
}


}

/// @nodoc
abstract mixin class _$MarketCopyWith<$Res> implements $MarketCopyWith<$Res> {
  factory _$MarketCopyWith(_Market value, $Res Function(_Market) _then) = __$MarketCopyWithImpl;
@override @useResult
$Res call({
 String marketId, String name, String type, List<MarketOutcome> outcomes
});




}
/// @nodoc
class __$MarketCopyWithImpl<$Res>
    implements _$MarketCopyWith<$Res> {
  __$MarketCopyWithImpl(this._self, this._then);

  final _Market _self;
  final $Res Function(_Market) _then;

/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? marketId = null,Object? name = null,Object? type = null,Object? outcomes = null,}) {
  return _then(_Market(
marketId: null == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,outcomes: null == outcomes ? _self._outcomes : outcomes // ignore: cast_nullable_to_non_nullable
as List<MarketOutcome>,
  ));
}


}


/// @nodoc
mixin _$MarketOutcome {

 String get outcomeId;/// What upstream calls this outcome: a team name, `"Draw"`, `"Over"`.
 String get label;/// Decimal odds — typed `double`, not inferred, for the same reason
/// `Selection.odds` is (`lib/models/selection.dart`): `jsonDecode` gives
/// `int` for a whole-number price and only a declared `double` makes the
/// generated `fromJson` coerce it.
 double get odds;
/// Create a copy of MarketOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketOutcomeCopyWith<MarketOutcome> get copyWith => _$MarketOutcomeCopyWithImpl<MarketOutcome>(this as MarketOutcome, _$identity);

  /// Serializes this MarketOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketOutcome&&(identical(other.outcomeId, outcomeId) || other.outcomeId == outcomeId)&&(identical(other.label, label) || other.label == label)&&(identical(other.odds, odds) || other.odds == odds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outcomeId,label,odds);

@override
String toString() {
  return 'MarketOutcome(outcomeId: $outcomeId, label: $label, odds: $odds)';
}


}

/// @nodoc
abstract mixin class $MarketOutcomeCopyWith<$Res>  {
  factory $MarketOutcomeCopyWith(MarketOutcome value, $Res Function(MarketOutcome) _then) = _$MarketOutcomeCopyWithImpl;
@useResult
$Res call({
 String outcomeId, String label, double odds
});




}
/// @nodoc
class _$MarketOutcomeCopyWithImpl<$Res>
    implements $MarketOutcomeCopyWith<$Res> {
  _$MarketOutcomeCopyWithImpl(this._self, this._then);

  final MarketOutcome _self;
  final $Res Function(MarketOutcome) _then;

/// Create a copy of MarketOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outcomeId = null,Object? label = null,Object? odds = null,}) {
  return _then(_self.copyWith(
outcomeId: null == outcomeId ? _self.outcomeId : outcomeId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketOutcome].
extension MarketOutcomePatterns on MarketOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketOutcome value)  $default,){
final _that = this;
switch (_that) {
case _MarketOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _MarketOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String outcomeId,  String label,  double odds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketOutcome() when $default != null:
return $default(_that.outcomeId,_that.label,_that.odds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String outcomeId,  String label,  double odds)  $default,) {final _that = this;
switch (_that) {
case _MarketOutcome():
return $default(_that.outcomeId,_that.label,_that.odds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String outcomeId,  String label,  double odds)?  $default,) {final _that = this;
switch (_that) {
case _MarketOutcome() when $default != null:
return $default(_that.outcomeId,_that.label,_that.odds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarketOutcome implements MarketOutcome {
  const _MarketOutcome({required this.outcomeId, required this.label, required this.odds});
  factory _MarketOutcome.fromJson(Map<String, dynamic> json) => _$MarketOutcomeFromJson(json);

@override final  String outcomeId;
/// What upstream calls this outcome: a team name, `"Draw"`, `"Over"`.
@override final  String label;
/// Decimal odds — typed `double`, not inferred, for the same reason
/// `Selection.odds` is (`lib/models/selection.dart`): `jsonDecode` gives
/// `int` for a whole-number price and only a declared `double` makes the
/// generated `fromJson` coerce it.
@override final  double odds;

/// Create a copy of MarketOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketOutcomeCopyWith<_MarketOutcome> get copyWith => __$MarketOutcomeCopyWithImpl<_MarketOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketOutcome&&(identical(other.outcomeId, outcomeId) || other.outcomeId == outcomeId)&&(identical(other.label, label) || other.label == label)&&(identical(other.odds, odds) || other.odds == odds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outcomeId,label,odds);

@override
String toString() {
  return 'MarketOutcome(outcomeId: $outcomeId, label: $label, odds: $odds)';
}


}

/// @nodoc
abstract mixin class _$MarketOutcomeCopyWith<$Res> implements $MarketOutcomeCopyWith<$Res> {
  factory _$MarketOutcomeCopyWith(_MarketOutcome value, $Res Function(_MarketOutcome) _then) = __$MarketOutcomeCopyWithImpl;
@override @useResult
$Res call({
 String outcomeId, String label, double odds
});




}
/// @nodoc
class __$MarketOutcomeCopyWithImpl<$Res>
    implements _$MarketOutcomeCopyWith<$Res> {
  __$MarketOutcomeCopyWithImpl(this._self, this._then);

  final _MarketOutcome _self;
  final $Res Function(_MarketOutcome) _then;

/// Create a copy of MarketOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outcomeId = null,Object? label = null,Object? odds = null,}) {
  return _then(_MarketOutcome(
outcomeId: null == outcomeId ? _self.outcomeId : outcomeId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
