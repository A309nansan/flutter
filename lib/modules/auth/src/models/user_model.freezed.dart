// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get socialPlatform; String get email; String get platformId; String get nickName;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.socialPlatform, socialPlatform) || other.socialPlatform == socialPlatform)&&(identical(other.email, email) || other.email == email)&&(identical(other.platformId, platformId) || other.platformId == platformId)&&(identical(other.nickName, nickName) || other.nickName == nickName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,socialPlatform,email,platformId,nickName);

@override
String toString() {
  return 'UserModel(socialPlatform: $socialPlatform, email: $email, platformId: $platformId, nickName: $nickName)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String socialPlatform, String email, String platformId, String nickName
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? socialPlatform = null,Object? email = null,Object? platformId = null,Object? nickName = null,}) {
  return _then(_self.copyWith(
socialPlatform: null == socialPlatform ? _self.socialPlatform : socialPlatform // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,platformId: null == platformId ? _self.platformId : platformId // ignore: cast_nullable_to_non_nullable
as String,nickName: null == nickName ? _self.nickName : nickName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.socialPlatform, required this.email, required this.platformId, required this.nickName});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String socialPlatform;
@override final  String email;
@override final  String platformId;
@override final  String nickName;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.socialPlatform, socialPlatform) || other.socialPlatform == socialPlatform)&&(identical(other.email, email) || other.email == email)&&(identical(other.platformId, platformId) || other.platformId == platformId)&&(identical(other.nickName, nickName) || other.nickName == nickName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,socialPlatform,email,platformId,nickName);

@override
String toString() {
  return 'UserModel(socialPlatform: $socialPlatform, email: $email, platformId: $platformId, nickName: $nickName)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String socialPlatform, String email, String platformId, String nickName
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? socialPlatform = null,Object? email = null,Object? platformId = null,Object? nickName = null,}) {
  return _then(_UserModel(
socialPlatform: null == socialPlatform ? _self.socialPlatform : socialPlatform // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,platformId: null == platformId ? _self.platformId : platformId // ignore: cast_nullable_to_non_nullable
as String,nickName: null == nickName ? _self.nickName : nickName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
