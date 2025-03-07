import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';

class KakaoSignInService {
  final authService = Modular.get<AuthService>();

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

      await authService.createOrGetUser(userModel);

      return user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
