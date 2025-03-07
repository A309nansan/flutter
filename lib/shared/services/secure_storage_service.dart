import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Access Token 저장
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: "access_token", value: token);
  }

  // Refresh Token 저장
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: "refresh_token", value: token);
  }

  // Access Token 가져오기
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: "access_token");
  }

  // Refresh Token 가져오기
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: "refresh_token");
  }

  // UserModel 저장
  static Future<void> saveUserModel(UserModel userModel) async {
    String userJson = jsonEncode(userModel.toJson());
    await _storage.write(key: "user_info", value: userJson);
  }

  // UserModel 가져오기
  static Future<UserModel?> getUserModel() async {
    String? userJson = await _storage.read(key: "user_info");
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  // 토큰 삭제(로그아웃)
  static Future<void> clearStorage() async {
    await _storage.deleteAll();
  }
}
