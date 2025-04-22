import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:nansan_flutter/shared/services/token_storage.dart';
import 'package:nansan_flutter/shared/widgets/toase_message.dart';
import '../../../../shared/services/request_service.dart';

class AuthService {
  /// 로그인 또는 회원가입 요청
  Future<void> createOrGetUser(UserModel userModel) async {
    try {
      // 공통 요청 함수 사용 (Dio 직접 사용해 response 전체 받음)
      final response = await RequestService.rawPost(
        '/user/login',
        data: userModel.toJson(),
      );

      final accessToken = response.data['access'];
      final refreshToken = response.headers['refresh']?.join();

      if (accessToken == null || refreshToken == null) {
        throw Exception("토큰 수신 실패");
      }

      // 토큰 저장
      await SecureStorageService.saveAccessToken(accessToken);
      await SecureStorageService.saveRefreshToken(refreshToken);
      TokenStorage.update(access: accessToken, refresh: refreshToken);

      // 사용자 정보 저장
      await SecureStorageService.saveUserModel(userModel);

      // 로그인 후 사용자 id 가져와서 저장 ("/user/me" 호출)
      await getUserId();

      bool status = await getStatus();
      if (status) {
        Modular.to.navigate('/profile');
      } else {
        Modular.to.navigate('/auth/role-select', arguments: userModel);
      }
      ToastMessage.show("로그인 되었습니다.");
    } catch (e) {
      debugPrint("❌ 로그인 에러: $e");
      ToastMessage.show("로그인에 실패했습니다. 다시 시도해주세요.");
    }
  }

  Future<bool> getStatus() async {
    try {
      final response = await RequestService.get("/user/user/detail-status");
      return response['detailStatus'];
    } catch (e) {
      debugPrint("❌ 아이 정보 불러오기 실패: $e");
      return false;
    }
  }

  Future<void> updateRole(String role) async {
    try {
      final response = await RequestService.patch(
        "/user/user/update-role",
        data: {"newRole": role},
      );
      await updateUserInfo();
      Modular.to.navigate("/profile");
      debugPrint("✅ role 업데이트 완료: $response");
    } catch (e) {
      debugPrint("❌ role 업데이트 실패: $e");
    }
  }

  /// "/user/me"를 호출하여 사용자 id를 받아와 secure storage에 저장하는 메서드
  Future<void> getUserId() async {
    try {
      final user = await RequestService.get("/user/me");
      final userId = user["id"];
      if (userId != null) {
        await SecureStorageService.saveUserIdFromResponse(userId);
        await SecureStorageService.saveUserInfoJson(jsonEncode(user));
      } else {
        debugPrint("사용자 id가 null입니다.");
      }
    } catch (e) {
      debugPrint("사용자 id 가져오기 실패: $e");
    }
  }

  Future<void> updateUserInfo() async {
    final user = await RequestService.get("/user/me");
    await SecureStorageService.saveUserInfoJson(jsonEncode(user));
  }

  /// 로그아웃 요청
  Future<void> logout() async {
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("Refresh Token 없음");
      }

      final response = await RequestService.rawPost(
        '/user/logout',
        headers: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        await SecureStorageService.clearAuthData();
        // await SecureStorageService.clearStorage();
        TokenStorage.clear();
        Modular.to.navigate('/login');
        ToastMessage.show("로그아웃 되었습니다.");
      } else {
        ToastMessage.show("로그아웃에 실패했습니다.");
      }
    } catch (e) {
      debugPrint("❌ 로그아웃 에러: $e");
      ToastMessage.show("로그아웃에 실패했습니다. 다시 시도해주세요.");
    }
  }
}
