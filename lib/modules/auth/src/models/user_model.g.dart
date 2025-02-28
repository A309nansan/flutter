// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  socialPlatform: json['socialPlatform'] as String,
  email: json['email'] as String,
  platformId: json['platformId'] as String,
  username: json['username'] as String,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'socialPlatform': instance.socialPlatform,
      'email': instance.email,
      'platformId': instance.platformId,
      'username': instance.username,
    };
