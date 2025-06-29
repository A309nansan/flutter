// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      socialPlatform: json['socialPlatform'] as String,
      email: json['email'] as String,
      platformId: json['platformId'] as String,
      nickName: json['nickName'] as String,
      role: (json['role'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'socialPlatform': instance.socialPlatform,
      'email': instance.email,
      'platformId': instance.platformId,
      'nickName': instance.nickName,
      'role': instance.role,
    };
