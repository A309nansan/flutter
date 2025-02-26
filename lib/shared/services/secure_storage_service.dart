import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // JWT 저장
  static Future<void> saveJwtToken(String token) async {
    await _storage.write(key: "access_token", value: token);
  }

  // Refresh Token 저장
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: "refresh_token", value: token);
  }

  // JWT 가져오기
  static Future<String?> getJwtToken() async {
    return await _storage.read(key: "access_token");
  }

  // Refresh Token 가져오기
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: "refresh_token");
  }

  // 토큰 삭제
  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
