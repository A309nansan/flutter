import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speech_balloon/speech_balloon.dart';
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
      // appBar: AppBar(
      //   title: const Text(
      //     "Nansan",
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      //   toolbarHeight: MediaQuery.of(context).size.width * 0.06,
      //   centerTitle: true,
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(),
            Container(
              width: 550,
              height: 300,
              margin: EdgeInsets.only(top: 320, bottom: 20),
              child: Image.asset("assets/images/logo1.png"),
            ),
            // const Text(
            //   '수학의 즐거움을 키우는 \n작은 씨앗',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            // ),
            Spacer(),
            Container(
              margin: EdgeInsets.all(50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(
                      (0.2 * 255).toInt(),
                    ), // 그림자 색상
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: SpeechBalloon(
                nipLocation: NipLocation.bottom,
                nipHeight: 25,
                borderRadius: 50,
                width: 370,
                height: 78,
                borderColor: const Color.fromARGB(111, 131, 131, 131),
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '3초만에 시작하기 🚀',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLoginButton(
                    const Color(0xFFFEE500),
                    Colors.black87,
                    "assets/images/kakao_logo.svg",
                    0.055,
                    context,
                    () => kakaoSignInService.signInWithKakao(),
                  ),
                  const SizedBox(width: 35),
                  _buildLoginButton(
                    Colors.white,
                    Colors.black87,
                    "assets/images/google_logo.svg",
                    0.05,
                    context,
                    () => googleSignInService.signInWithGoogle(),
                  ),
                  const SizedBox(width: 35),
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
    double buttonSize = MediaQuery.of(context).size.width * 0.1;
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
