import 'package:flutter/material.dart';

class MathUIConstant {
  static late double screenWidth;
  static late double screenHeight;
  static late bool isTesting;
  static late double MQC;

  static final MathUIConstant instance = MathUIConstant._internal();

  MathUIConstant._internal();

  void init({required MediaQueryData mediaQuery, required bool isTest}) {
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    MathUIConstant.isTesting = isTest;
    debugPrint("SCREENWIDTH: $screenWidth");
    MQC = screenWidth / 800;
  }

  /// ✅ MediaQuery 비율 계산 (예: 2560 기준 스케일링)

  //BASA M 사칙연산 규격
  static double get wSize => 100.0 * MQC;
  static double get hSize => 100.0 * MQC;
  static double get fSize => 60.0 * MQC;
  static double get opSize => 50.0 * MQC;
  static double get iconSize => 80.0 * MQC;

  //BASA M의 버튼 크기 규격
  static double get buttonWidth => 170 * MQC;
  static double get buttonHeight => 50 * MQC;
  static double get buttonFontSize => 20 * MQC;

  //BASA M의 indexCounter 규격
  static double get indexIconFontSize => 40.0 * MQC;
  static double get indexIconSize => 80 * MQC;

  //BASA M의 아이콘 사이즈 규격
  static double get refreshIconSize => 50 * MQC;
  static double get helperIconSize => 40 * MQC;
  static double get helperIconSizeSmall => 30 * MQC;

  //BASA M dialog 크기 규격 (Information용)
  static double get dialogHeight => 700 * MQC;
  static double get dialogWidth => 500 * MQC;

  //divider 관련 상수
  static double get divisorHeight => 7.5 * MQC;
  static double get dividerHeight => 2 * MQC;

  //statsdialog
  static double get statsDialogWidth => 600 * MQC;
  static double get statsDialogHeight => 900 * MQC;
  static int get loadingTime => 1200;

  static const Color backgroundBasic = Color(0xFFFFFBF4);

  static const Color greenShadow = Colors.green;
  static const Color redShadow = Colors.red;
  static const Color activeButtonColor = Color(0xFFFFFAE1);
  static const Color activeButtonColorSecond = Color(0xFFFFFCF1);
  static const Color dividerColor = Color(0xFFAAAAAA);
  static const Color blackFontColor = Color(0xFF3c3c43);
  static const Color rightAnswerColor = Color(0xFF0d632d);
  static const Color wrongAnswerColor = Color(0xFF801919);
  static const Color inputBoundaryColor = Color(0xFFAAAAAA);
  static const Color semiTransparentMarginColor = Color(0xFFE0E0E0);

  static Color get boundaryBlue =>
      !isTesting ? Colors.transparent : Colors.blueAccent;
  static Color get boundaryCyan =>
      !isTesting ? Colors.transparent : Colors.cyanAccent;
  static Color get boundaryTeal =>
      !isTesting ? Colors.transparent : Colors.tealAccent;
  static Color get boundaryOrange =>
      !isTesting ? Colors.transparent : Colors.orangeAccent;
  static Color get boundaryGreen =>
      !isTesting ? Colors.transparent : Colors.greenAccent;
  static Color get boundaryPurple =>
      !isTesting ? Colors.transparent : Colors.purpleAccent;
  static Color get boundaryTransparent => Colors.transparent;

  static double statsTransformConstant(int c){
    if ([101,102,].contains(c)) return 0.8; // Linear, 한자리
    if ([103].contains(c)) return 0.65; // Linear 한자리 더
    if ([104,501].contains(c)) return 0.7; // Linear 한자리 더
    if([201,202,203,204,301,302,303,304].contains(c)) return 0.9; //가로로 두줄
    if([401,402,403,404,502].contains(c)) return 0.8; //가로로 세줄
    if([504, 601, 602, 603].contains(c)) return 0.7; //가로로 네줄
    if([503, 604].contains(c)) return 0.55; //가로로 다섯줄
    return 1;
  }

}
