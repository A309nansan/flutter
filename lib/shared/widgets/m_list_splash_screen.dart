import 'dart:async';
import 'package:flutter/material.dart';

class MListSplashScreen extends StatefulWidget {
  const MListSplashScreen({super.key});

  @override
  State<MListSplashScreen> createState() => _MListSplashScreenState();
}

class _MListSplashScreenState extends State<MListSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  final List<String> loadingMessages = [
    '통계 결과를 불러오고 있어요',
    '기대해도 괜찮을까요?',
    '풀이 데이터 수집중..',
  ];
  final List<String> loadingImages = [
    'assets/images/basa_math/doctor_bunny.webp',
    'assets/images/basa_math/doctor_bunny.webp',
    'assets/images/basa_math/doctor_bunny.webp',
  ];

  String _dots = '';
  Timer? _dotTimer;
  double _opacity = 0.0;
  late final String _baseMessage;
  late final String _baseImage;

  @override
  void initState() {
    super.initState();

    _baseMessage = (loadingMessages..shuffle()).first;
    _baseImage = (loadingImages..shuffle()).first;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _progressAnimation =
    Tween<double>(begin: 0.0, end: 1.0).animate(_progressController)
      ..addListener(() {
        setState(() {});
      });

    _progressController.forward();

    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dots = '.' * ((timer.tick % 4));
      });
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
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
              Image.asset(
                _baseImage,
                scale: 1.8,
              ),
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
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFF9c6a17),
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
