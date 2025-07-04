// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildProfileModelImpl _$$ChildProfileModelImplFromJson(
  Map<String, dynamic> json,
) => _$ChildProfileModelImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  profileImageUrl: json['profileImageUrl'] as String,
  birthDate: json['birthDate'] as String,
  grade: json['grade'] as String,
  gender: json['gender'] as String,
  equipItem:
      json['equippedItemsResponse'] == null
          ? const equippedItemsResponse(
            background: {"itemCode": 101},
            character: {"itemCode": 201},
            clothes: [],
            accessories: [],
          )
          : equippedItemsResponse.fromJson(json['equippedItemsResponse'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ChildProfileModelImplToJson(
  _$ChildProfileModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'profileImageUrl': instance.profileImageUrl,
  'birthDate': instance.birthDate,
  'grade': instance.grade,
  'gender': instance.gender,
  'equippedItemsResponse': instance.equipItem,
};
