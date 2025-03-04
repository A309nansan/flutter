import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nansan_flutter/modules/auth/src/models/user_model.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      String? googleIdToken = auth.idToken;

      debugPrint(account.toString());

      UserModel userModel = UserModel(
        socialPlatform: "socialPlatform",
        email: "email",
        platformId: "platformId",
        username: "username",
      );
      // await AuthService.sendTokenToBackend("google", googleIdToken!);

      return account;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
