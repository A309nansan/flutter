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

      String email = user.kakaoAccount!.email!;
      String platformId = user.id.toString();
      String userName = user.kakaoAccount!.profile!.nickname!;

      UserModel userModel = UserModel(
        socialPlatform: "kakao",
        email: email,
        platformId: "kakao-$platformId",
        nickName: userName,
      );

      await AuthService.createOrGetUser(userModel);

      return user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
