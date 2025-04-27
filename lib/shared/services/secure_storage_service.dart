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

  static Future<void> saveUserInfoJson(String json) async {
    await _storage.write(key: "user_info_full", value: json);
  }

  static Future<Map<String, dynamic>?> getUserInfoJson() async {
    final jsonStr = await _storage.read(key: "user_info_full");
    return jsonStr != null ? jsonDecode(jsonStr) : null;
  }

  // 서버에서 받아온 사용자 id를 "userId" 키로 저장
  static Future<void> saveUserIdFromResponse(dynamic id) async {
    await _storage.write(key: "userId", value: id.toString());
  }

  // 저장된 사용자 id 가져오기
  static Future<String?> getUserId() async {
    return await _storage.read(key: "userId");
  }

  // 전체 초기화
  static Future<void> clearStorage() async {
    await _storage.deleteAll();
  }

  // 로그아웃
  static Future<void> clearAuthData() async {
    await _storage.delete(key: "access_token");
    await _storage.delete(key: "refresh_token");
    await _storage.delete(key: "user_info");
    await _storage.delete(key: "userId");
    await _storage.delete(key: "child_profile");
  }

  static Future<void> saveChildProfile(String json) async {
    await _storage.write(key: 'child_profile', value: json);
  }

  static Future<String?> getChildProfile() async {
    return await _storage.read(key: 'child_profile');
  }

  static Future<void> deleteChildProfile() async {
    await _storage.delete(key: 'child_profile');
  }

  static Future<int?> getChildId() async {
    final childProfileJson = await SecureStorageService.getChildProfile();
    final childProfile = jsonDecode(childProfileJson!);
    final childId = childProfile['id'];

    return childId;
  }

  // 개인정보 동의 여부 저장
  static Future<void> setPrivacyAgreementStatus(bool agreed) async {
    await _storage.write(key: 'privacy_agreed', value: agreed.toString());
  }

  // 개인정보 동의 여부 가져오기
  static Future<bool> getPrivacyAgreementStatus() async {
    String? value = await _storage.read(key: 'privacy_agreed');
    return value == 'true';
  }

  // 개인정보 동의 여부 삭제 (선택적으로 활용 가능)
  static Future<void> clearPrivacyAgreementStatus() async {
    await _storage.delete(key: 'privacy_agreed');
  }

}
