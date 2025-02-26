import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';

class KakaoSignInService {
  static Future<User?> signInWithKakao() async {
    try {
      bool isKakaoInstalled = await isKakaoTalkInstalled();
      OAuthToken token =
          isKakaoInstalled
              ? await UserApi.instance.loginWithKakaoTalk()
              : await UserApi.instance.loginWithKakaoAccount();

      User user = await UserApi.instance.me();

      await AuthService.sendTokenToBackend("kakao", token.accessToken);

      return user;
    } catch (e, stackTrace) {
      return null;
    }
  }
}
