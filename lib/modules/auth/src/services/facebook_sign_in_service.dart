import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';

class FacebookSignInService {
  static final Dio _dio = Dio();
  final authService = Modular.get<AuthService>();

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        final response = await _dio.get(
          'https://graph.facebook.com/v2.12/me',
          queryParameters: {
            'fields': 'email,name',
            'access_token': loginResult.accessToken!.tokenString,
          },
        );

        final profileInfo = json.decode(response.data);

        String email = profileInfo['email'];
        String platformId = profileInfo['id'];
        String userName = profileInfo['name'];

        UserModel userModel = UserModel(
          socialPlatform: "face_book",
          email: email,
          platformId: "facebook-$platformId",
          nickName: userName,
        );


        await authService.createOrGetUser(userModel);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
