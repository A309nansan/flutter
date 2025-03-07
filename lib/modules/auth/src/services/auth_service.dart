import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:nansan_flutter/shared/widgets/toase_message.dart';

class AuthService {
  static final Dio _dio = Dio();

  Future<void> createOrGetUser(UserModel userModel) async {
    try {
      final response = await _dio.post(
        "http://10.0.2.2:8080/api/v1/login",
        data: userModel.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        String accessToken = response.data['access'];
        String refreshToken = response.headers['refresh']!.join();

        // access/refresh token 저장
        await SecureStorageService.saveAccessToken(accessToken);
        await SecureStorageService.saveRefreshToken(refreshToken);

        // 사용자 정보 저장
        await SecureStorageService.saveUserModel(userModel);

        // main screen으로 이동
        Modular.to.navigate('/main');

        ToastMessage.show("로그인 되었습니다.");
      } else {
        ToastMessage.show("잠시 후 다시 시도해주세요.");
      }
    } catch (e) {
      debugPrint("에러 ${e.toString()}");
    }
  }

  Future<void> logout() async {
    try {
      String? refreshToken = await SecureStorageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("Refresh Token 없음");
      }

      final response = await _dio.post(
        "http://10.0.2.2:8080/api/v1/logout",

        options: Options(
          headers: {
            "Content-Type": "application/json",
            "refresh": refreshToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        SecureStorageService.clearStorage();

        Modular.to.navigate('/login');

        ToastMessage.show("로그아웃 되었습니다.");
      } else {
        ToastMessage.show("로그아웃에 실패했습니다. 잠시 후 다시 시도해주세요.");
      }
    } catch (e) {
      debugPrint("에러 ${e.toString()}");
    }
  }
}
