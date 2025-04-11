// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChildProfileModel _$ChildProfileModelFromJson(Map<String, dynamic> json) =>
    _ChildProfileModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
      birthDate: json['birthDate'] as String,
      grade: json['grade'] as String,
      gender: json['gender'] as String,
    );

Map<String, dynamic> _$ChildProfileModelToJson(_ChildProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profileImageUrl': instance.profileImageUrl,
      'birthDate': instance.birthDate,
      'grade': instance.grade,
      'gender': instance.gender,
    };
