import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speech_balloon/speech_balloon.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../services/facebook_sign_in_service.dart';
import '../services/kakao_sign_in_service.dart';
import '../services/google_sign_in_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final kakaoSignInService = Modular.get<KakaoSignInService>();
    final googleSignInService = Modular.get<GoogleSignInService>();
    final facebookSignInService = Modular.get<FacebookSignInService>();

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: screenHeight * 0.1),
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.2,
                    child: Image.asset("assets/images/logo1.png"),
                  ),
                  Text(
                    "수학을 키우는 작은 씨앗, \n한 걸음씩 수학의 숲으로!",
                    style: TextStyle(
                      fontFamily: "SingleDay",
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C6A17),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.15),
                child: Column(
                  children: [
                    BouncingSpeechBalloon(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLoginButton(
                          const Color(0xFFFEE500),
                          Colors.black87,
                          "assets/images/kakao_logo.svg",
                          0.055,
                          context,
                          () async {
                            final alreadyAgreed = await SecureStorageService.getPrivacyAgreementStatus();
                            if (!alreadyAgreed) {
                              final agreed = await Modular.to.pushNamed<bool>('/auth/privacy-agreement');

                              if (agreed != true) return;
                            }
                            await kakaoSignInService.signInWithKakao();
                          },
                        ),
                        const SizedBox(width: 40),
                        _buildLoginButton(
                          Colors.white,
                          Colors.black87,
                          "assets/images/google_logo.svg",
                          0.05,
                          context,
                          () async {
                            final alreadyAgreed = await SecureStorageService.getPrivacyAgreementStatus();
                            if (!alreadyAgreed) {
                              final agreed = await Modular.to.pushNamed<bool>('/auth/privacy-agreement');

                              if (agreed != true) return;
                            }
                            await googleSignInService.signInWithGoogle();
                          },
                        ),
                        const SizedBox(width: 40),
                        _buildLoginButton(
                          Colors.white,
                          Colors.black87,
                          "assets/images/facebook_logo.svg",
                          1,
                          context,
                          () async {
                            final alreadyAgreed = await SecureStorageService.getPrivacyAgreementStatus();
                            if (!alreadyAgreed) {
                              final agreed = await Modular.to.pushNamed<bool>('/auth/privacy-agreement');

                              if (agreed != true) return;
                            }
                            await facebookSignInService.signInWithFacebook();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

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
          nipHeight: screenHeight * 0.015,
          borderRadius: 50,
          width: screenWidth * 0.35,
          height: screenHeight * 0.05,
          borderColor: const Color.fromARGB(111, 131, 131, 131),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '3초만에 시작하기 🚀',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
