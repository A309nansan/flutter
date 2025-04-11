import 'package:flutter/material.dart';

import '../utils/math_ui_constant.dart';

class MLectureLoadingScreen extends StatefulWidget {
  final bool isTeachingMode;

  const MLectureLoadingScreen({super.key, required this.isTeachingMode});

  @override
  State<MLectureLoadingScreen> createState() => _MLectureLoadingScreenState();
}

class _MLectureLoadingScreenState extends State<MLectureLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: MathUIConstant.loadingTime),
    )..forward();

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_progressController);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.isTeachingMode ? "선생님과 함께 풀기" : "혼자 학습하기",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 70),
          // ✅ 부드러운 그림자와 라운딩 처리된 이미지 박스
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                widget.isTeachingMode
                    ? 'assets/images/basa_math/tutorial.png'
                    : 'assets/images/basa_math/practice.png',
                // ✅ 원하는 이미지로 교체 가능
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "문제를 준비 중이에요...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          // ✅ 로딩 바
          SizedBox(
            width: 200,
            height: 6,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isTeachingMode
                        ? Colors.purple
                        : Colors.teal, // 상황에 따라 색상 다르게
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
