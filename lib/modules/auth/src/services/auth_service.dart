import 'package:dio/dio.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';

class AuthService {
  static final Dio _dio = Dio();

  static Future<void> sendTokenToBackend(String provider, String token) async {
    try {
      final response = await _dio.post(
        "http://10.0.2.2:8080/api/auth2/$provider",
        data: {"token": token},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      await SecureStorageService.saveJwtToken(response.data['jwt']);
      await SecureStorageService.saveRefreshToken(
        response.data['refreshToken'],
      );
    } catch (e) {
      print("에러 ${e}");
    }
  }
}
