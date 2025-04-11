import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:nansan_flutter/shared/digit_recognition/services/recognition_service.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:nansan_flutter/shared/services/token_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'modules/auth/src/services/auth_service.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final AuthService authService = Modular.get<AuthService>();

  final List<String> loadingMessages = [
    '깡총깡총 오는 중',
    '토끼가 길을 찾고 있어요',
    '금방 시작할게요',
  ];

  String _dots = '';
  Timer? _dotTimer;
  double _opacity = 1.0;
  late final String _baseMessage;

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    _baseMessage = (loadingMessages..shuffle()).first;

    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        _dots = '.' * ((timer.tick % 4));
      });
    });

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await animateProgressTo(0.1);
      await dotenv.load(fileName: ".env");

      await animateProgressTo(0.2);
      KakaoSdk.init(
        nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'],
        javaScriptAppKey: dotenv.env['KAKAO_JAVASCRIPT_APP_KEY'],
      );

      await animateProgressTo(0.3);
      await initializeDateFormatting();

      await animateProgressTo(0.4);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await animateProgressTo(0.5);
      try {
        await DigitalInkRecognitionService.instance.initialize(languageCode: 'ko');
      } catch (e) {
        debugPrint('🛑 인식 모델 초기화 중 오류 발생: $e');
      }

      await animateProgressTo(0.6);
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      await animateProgressTo(0.8);
      await TokenStorage.initFromStorage();

      await animateProgressTo(1.0);
      await Future.delayed(const Duration(milliseconds: 400));
      _dotTimer?.cancel();

      if (!mounted) return;
      await _checkLoginStatus();
    } catch (e) {
      debugPrint('앱 초기화 중 오류 발생: $e');
      Modular.to.navigate('/login');
    }
  }

  /// 부드럽게 로딩바를 올려주는 함수
  Future<void> animateProgressTo(double target) async {
    const step = 0.01;
    const totalDuration = Duration(milliseconds: 300);

    final start = _progress;
    final diff = target - start;
    final count = (diff / step).abs();

    if (count == 0) return;

    final interval = totalDuration.inMilliseconds ~/ count;

    for (int i = 1; i <= count; i++) {
      if (!mounted) return;
      await Future.delayed(Duration(milliseconds: interval));
      setState(() {
        _progress = (start + (step * i)).clamp(0.0, 1.0);
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final accessToken = await SecureStorageService.getAccessToken();
    final user = await SecureStorageService.getUserModel();

    if (accessToken != null && accessToken.isNotEmpty && user != null) {
      final status = await authService.getStatus();
      if (status) {
        Modular.to.navigate('/profile');
      } else {
        Modular.to.navigate('/auth/role-select', arguments: user);
      }
    } else {
      Modular.to.navigate('/login');
    }
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_baseMessage$_dots',
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9c6a17),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
