import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:nansan_flutter/app_module.dart';
import 'package:nansan_flutter/shared/digit_recognition/services/recognition_service.dart';
import 'package:nansan_flutter/shared/services/token_storage.dart';

import 'modules/math/src/utils/math_ui_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  String? kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
  String? kakaoJavaScriptAppKey = dotenv.env['KAKAO_JAVASCRIPT_APP_KEY'];
  KakaoSdk.init(
    nativeAppKey: kakaoNativeAppKey,
    javaScriptAppKey: kakaoJavaScriptAppKey,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 수학 숫자 인식을 위한 언어 모델로 초기화
  try {
    await DigitalInkRecognitionService.instance.initialize(languageCode: 'ko');
  } catch (e) {
    debugPrint('🛑 인식 모델 초기화 중 오류 발생: $e');
  }


  // 모든 요청에서 인터셉터가 자동으로 accessToken을 붙일 수 있도록 초기화
  await TokenStorage.initFromStorage();
  runApp(ModularApp(module: AppModule(), child: MyApp()));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // 💡 MediaQuery 초기화
        final MQC = MediaQuery.of(context);
        MathUIConstant.instance.init(
          mediaQuery: MQC,
          isTest: false, // or true based on app logic
        );

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Nansan',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 249, 241, 196),
            ),
          ),
          routeInformationParser: Modular.routeInformationParser,
          routerDelegate: Modular.routerDelegate,
        );
      },
    );
  }
}