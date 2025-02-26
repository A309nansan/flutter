import 'package:google_sign_in/google_sign_in.dart';
import 'package:nansan_flutter/modules/auth/src/services/auth_service.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      String? googleIdToken = auth.idToken;

      await AuthService.sendTokenToBackend("google", googleIdToken!);

      return account;
    } catch (e, stackTrace) {
      return null;
    }
  }
}
