import 'package:nansan_flutter/shared/services/secure_storage_service.dart';

class TokenStorage {
  static String? accessToken;
  static String? refreshToken;

  static void update({required String access, required String refresh}) {
    accessToken = access;
    refreshToken = refresh;
  }

  static void clear() {
    accessToken = null;
    refreshToken = null;
  }

  static Future<void> initFromStorage() async {
    accessToken = await SecureStorageService.getAccessToken();
    refreshToken = await SecureStorageService.getRefreshToken();
  }
}