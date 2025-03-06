import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';

class AuthService {
  static final Dio _dio = Dio();

  static Future<void> createOrGetUser(UserModel userModel) async {
    try {
      final response = await _dio.post(
        "http://10.0.2.2:8080/api/v1/login",
        data: userModel.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      debugPrint(response.data['access'].toString());

      // String? accessToken = response.data.access;
      // await SecureStorageService.saveJwtToken(response.data['jwt']);
      // await SecureStorageService.saveRefreshToken(
      //   response.data['refreshToken'],
      // );
    } catch (e) {
      print("에러 ${e}");
    }
  }
}
