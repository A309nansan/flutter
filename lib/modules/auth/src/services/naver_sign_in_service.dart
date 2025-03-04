import 'package:flutter/widgets.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';

class NaverSignInService {
  Future<NaverAccountResult?> signInWithNaver() async {
    try {
      // 네이버 로그인 시도
      NaverLoginResult loginResult = await FlutterNaverLogin.logIn();

      // 로그인 성공 후 사용자 정보 반환
      if (loginResult.status == NaverLoginStatus.loggedIn) {
        NaverAccountResult user = loginResult.account;
        // 사용자 정보 출력
        print('UserInfo: ${user}');
        UserModel userModel = UserModel(
          socialPlatform: "socialPlatform",
          email: "email",
          platformId: "platformId",
          username: "username",
        );
        // await AuthService.sendTokenToBackend("naver", loginResult.accessToken);

        return user;
      } else {
        return null;
      }
    } catch (e) {
      // 예외 처리
      debugPrint('Naver login error: $e');
      return null;
    }
  }
}
