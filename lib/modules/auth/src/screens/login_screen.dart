import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../services/kakao_sign_in_service.dart';
import '../services/google_sign_in_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Modular.get<KakaoSignInService>();
    Modular.get<GoogleSignInService>();

    return Scaffold(
      appBar: AppBar(title: const Text("소셜 로그인")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoginButton(
              "카카오 로그인",
              const Color(0xFFFEE500),
              Colors.black87,
              () => KakaoSignInService.signInWithKakao(),
            ),
            const SizedBox(height: 20),
            _buildLoginButton(
              "구글 로그인",
              Colors.white,
              Colors.black87,
              () => GoogleSignInService.signInWithGoogle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    String text,
    Color bgColor,
    Color fgColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
