import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/kakao_sign_in_service.dart';
import '../services/google_sign_in_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kakaoSignInService = Modular.get<KakaoSignInService>();
    final googleSignInService = Modular.get<GoogleSignInService>();
    // final naverSignInService = Modular.get<NaverSignInService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nansan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 153, 209, 255),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoginButton(
              "카카오 로그인",
              const Color(0xFFFEE500),
              Colors.black87,
              "lib/assets/kakao_logo.svg",
              () => kakaoSignInService.signInWithKakao(),
            ),
            const SizedBox(height: 20),
            _buildLoginButton(
              "구글 로그인",
              Colors.white,
              Colors.black87,
              "lib/assets/google_logo.svg",
              () => googleSignInService.signInWithGoogle(),
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
    String logo,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SvgPicture.asset(logo, height: 30.0, width: 30.0),
            ),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
