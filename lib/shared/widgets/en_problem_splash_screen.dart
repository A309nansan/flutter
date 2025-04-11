import 'dart:async';
import 'package:flutter/material.dart';

class EnProblemSplashScreen extends StatefulWidget {
  const EnProblemSplashScreen({super.key});

  @override
  State<EnProblemSplashScreen> createState() => _EnProblemSplashScreenState();
}

class _EnProblemSplashScreenState extends State<EnProblemSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  final List<String> loadingMessages = [
    '토끼가 문제를 꺼내고 있어요',
    '과일을 세는 중이에요',
    '문제를 준비 중이에요',
  ];
  final List<String> loadingImages = [
    'assets/images/problem_loading1.webp',
    'assets/images/problem_loading2.webp',
    'assets/images/problem_loading3.webp',
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
