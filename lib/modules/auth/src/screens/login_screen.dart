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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 525,
              height: 300,
              margin: EdgeInsets.only(top: 320, bottom: 20),
              child: Image.asset("assets/images/logo2.png"),
            ),
            SizedBox(
              child: const Text(
                "수학을 키우는 작은 씨앗, \n한 걸음씩 수학의 숲으로!",
                style: TextStyle(
                  fontFamily: "SingleDay",
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C6A17),
                ),
              ),
            ),
            Spacer(),
            BouncingSpeechBalloon(),
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
                  const SizedBox(width: 40),
                  _buildLoginButton(
                    Colors.white,
                    Colors.black87,
                    "assets/images/google_logo.svg",
                    0.05,
                    context,
                    () => googleSignInService.signInWithGoogle(),
                  ),
                  const SizedBox(width: 40),
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
          minimumSize: Size.zero,
          elevation: 3,
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

class BouncingSpeechBalloon extends StatefulWidget {
  const BouncingSpeechBalloon({super.key});

  @override
  BouncingSpeechBalloonState createState() => BouncingSpeechBalloonState();
}

class BouncingSpeechBalloonState extends State<BouncingSpeechBalloon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.all(50),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
