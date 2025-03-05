import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/facebook_sign_in_service.dart';
import '../services/kakao_sign_in_service.dart';
import '../services/google_sign_in_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kakaoSignInService = Modular.get<KakaoSignInService>();
    final googleSignInService = Modular.get<GoogleSignInService>();
    final facebookSignInService = Modular.get<FacebookSignInService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nansan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        toolbarHeight: MediaQuery.of(context).size.width * 0.06,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoginButton(
                  const Color(0xFFFEE500),
                  Colors.black87,
                  "assets/images/kakao_logo.svg",
                  0.040,
                  context,
                  () => kakaoSignInService.signInWithKakao(),
                ),
                const SizedBox(width: 25),
                _buildLoginButton(
                  Colors.white,
                  Colors.black87,
                  "assets/images/google_logo.svg",
                  0.040,
                  context,
                  () => googleSignInService.signInWithGoogle(),
                ),
                const SizedBox(width: 25),
                _buildLoginButton(
                  Colors.white,
                  Colors.black87,
                  "assets/images/facebook_logo.svg",
                  1,
                  context,
                  () => facebookSignInService.signInWithFacebook(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    Color bgColor,
    Color fgColor,
    String logo,
    double logoSize,
    BuildContext context,
    VoidCallback onPressed,
  ) {
    double buttonSize = MediaQuery.of(context).size.width * 0.085;
    double iconSize = MediaQuery.of(context).size.width * logoSize;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: SvgPicture.asset(
          logo,
          height: iconSize,
          width: iconSize,
          fit: BoxFit.cover,
          allowDrawingOutsideViewBox: true,
        ),
      ),
    );
  }
}
