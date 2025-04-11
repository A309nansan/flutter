// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChildProfileModel {

 int get id; String get name; String get profileImageUrl; String get birthDate; String get grade; String get gender;
/// Create a copy of ChildProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildProfileModelCopyWith<ChildProfileModel> get copyWith => _$ChildProfileModelCopyWithImpl<ChildProfileModel>(this as ChildProfileModel, _$identity);

  /// Serializes this ChildProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.gender, gender) || other.gender == gender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,profileImageUrl,birthDate,grade,gender);

@override
String toString() {
  return 'ChildProfileModel(id: $id, name: $name, profileImageUrl: $profileImageUrl, birthDate: $birthDate, grade: $grade, gender: $gender)';
}


}

/// @nodoc
abstract mixin class $ChildProfileModelCopyWith<$Res>  {
  factory $ChildProfileModelCopyWith(ChildProfileModel value, $Res Function(ChildProfileModel) _then) = _$ChildProfileModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, String profileImageUrl, String birthDate, String grade, String gender
});




}
/// @nodoc
class _$ChildProfileModelCopyWithImpl<$Res>
    implements $ChildProfileModelCopyWith<$Res> {
  _$ChildProfileModelCopyWithImpl(this._self, this._then);

  final ChildProfileModel _self;
  final $Res Function(ChildProfileModel) _then;

/// Create a copy of ChildProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? profileImageUrl = null,Object? birthDate = null,Object? grade = null,Object? gender = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: null == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ChildProfileModel implements ChildProfileModel {
  const _ChildProfileModel({required this.id, required this.name, required this.profileImageUrl, required this.birthDate, required this.grade, required this.gender});
  factory _ChildProfileModel.fromJson(Map<String, dynamic> json) => _$ChildProfileModelFromJson(json);

@override final  int id;
@override final  String name;
@override final  String profileImageUrl;
@override final  String birthDate;
@override final  String grade;
@override final  String gender;

/// Create a copy of ChildProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildProfileModelCopyWith<_ChildProfileModel> get copyWith => __$ChildProfileModelCopyWithImpl<_ChildProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChildProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.gender, gender) || other.gender == gender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,profileImageUrl,birthDate,grade,gender);

@override
String toString() {
  return 'ChildProfileModel(id: $id, name: $name, profileImageUrl: $profileImageUrl, birthDate: $birthDate, grade: $grade, gender: $gender)';
}


}

/// @nodoc
abstract mixin class _$ChildProfileModelCopyWith<$Res> implements $ChildProfileModelCopyWith<$Res> {
  factory _$ChildProfileModelCopyWith(_ChildProfileModel value, $Res Function(_ChildProfileModel) _then) = __$ChildProfileModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String profileImageUrl, String birthDate, String grade, String gender
});




}
/// @nodoc
class __$ChildProfileModelCopyWithImpl<$Res>
    implements _$ChildProfileModelCopyWith<$Res> {
  __$ChildProfileModelCopyWithImpl(this._self, this._then);

  final _ChildProfileModel _self;
  final $Res Function(_ChildProfileModel) _then;

/// Create a copy of ChildProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? profileImageUrl = null,Object? birthDate = null,Object? grade = null,Object? gender = null,}) {
  return _then(_ChildProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: null == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
