
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/evaluation_status.dart';
import '../../services/feedback_animator_service.dart';

class FeedbackLottieWidget extends StatefulWidget {
  final String asset;
  const FeedbackLottieWidget({super.key, required this.asset});

  @override
  State<FeedbackLottieWidget> createState() => FeedbackLottieWidgetState();
}

class FeedbackLottieWidgetState extends State<FeedbackLottieWidget> with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;



  BoxFit _getBoxFit() {
    if (widget.asset.contains('confetti')) {
      return BoxFit.cover;
    }
    return BoxFit.contain;
  }

  double _getPlaybackSpeed() {
    if (widget.asset.contains('cross_mark')) {
      return 0.3; // 빨리 재생
    } else if (widget.asset.contains('confetti')) {
      return 0.8;
    }
    return 0.5; // 기본 속도
  }

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fadeController.forward(); // fade out 시작
        Future.delayed(const Duration(milliseconds: 400), () {
          FeedbackAnimatorService().clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: FadeTransition(
          opacity: ReverseAnimation(_fadeAnimation),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth * 0.8;
                final height = constraints.maxWidth * 0.8;
                final fit = _getBoxFit();
                final speedFactor = _getPlaybackSpeed();

                final lottie = Lottie.asset(
                  widget.asset,
                  controller: _lottieController,
                  onLoaded: (composition) {
                    _lottieController
                      ..duration = composition.duration * speedFactor
                      ..forward();
                  },
                  repeat: false,
                  width: width,
                  height: height,
                  fit: fit,
                );

                // 🎯 "correct.json"일 경우만 Transform 적용해서 1:1 비율처럼 보이게
                if (widget.asset.contains('correct')) {
                  return Transform.scale(
                    scaleX: 1.2, // 가로만 줄이기
                    scaleY: 1.8,
                    alignment: Alignment.center,
                    child: lottie,
                  );
                } else {
                  return lottie;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
String getAnimationAsset(EvaluationStatus status) {
  switch (status) {
    case EvaluationStatus.correct:
      return 'assets/lottie/correct.json';
    case EvaluationStatus.wrong:
      return 'assets/lottie/cross_mark_animation.json';
    case EvaluationStatus.checked:
      return 'assets/lottie/confetti.json';
    case EvaluationStatus.unSolved:
    default:
      return 'assets/lottie/correct.json'; // 또는 null-safe 처리
  }
}