import 'package:flutter/widgets.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';

class KakaoSignInService {
  Future<User?> signInWithKakao() async {
    try {
      bool isKakaoInstalled = await isKakaoTalkInstalled();
      OAuthToken token =
          isKakaoInstalled
              ? await UserApi.instance.loginWithKakaoTalk()
              : await UserApi.instance.loginWithKakaoAccount();

      User user = await UserApi.instance.me();
      debugPrint(user.toString());

      UserModel userModel = UserModel(
        socialPlatform: "socialPlatform",
        email: "email",
        platformId: "platformId",
        username: "username",
      );
      // await AuthService.sendTokenToBackend("kakao", token.accessToken);

      return user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
