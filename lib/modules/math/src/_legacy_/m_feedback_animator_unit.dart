//
// import 'package:flutter/animation.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import '../screens/m_lecture_screen.dart';
//
// class FeedbackAnimator {
//   final TickerProvider vsync;
//   late final AnimationController lottieController;
//   late final AnimationController fadeController;
//   late final Animation<double> fadeAnimation;
//
//   FeedbackAnimator({required this.vsync}) {
//     lottieController = AnimationController(
//       vsync: vsync,
//       duration: const Duration(seconds: 1),
//     );
//
//     fadeController = AnimationController(
//       vsync: vsync,
//       duration: const Duration(seconds: 1),
//     );
//
//     fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(fadeController);
//   }
//
//   void play() {
//     lottieController.reset();
//     fadeController.reset();
//     lottieController.forward();
//     fadeController.forward();
//   }
//
//   void dispose() {
//     lottieController.dispose();
//     fadeController.dispose();
//   }
//
//   Widget build({required EvaluationStatus isCorrect}) {
//     String asset = '';
//     switch (isCorrect) {
//       case EvaluationStatus.correct:
//         asset = 'assets/lottie/correct.json';
//         break;
//       case EvaluationStatus.wrong:
//         asset = 'assets/lottie/cross_mark_animation.json';
//         break;
//       case EvaluationStatus.checked:
//         asset = 'assets/lottie/confetti.json';
//         break;
//       default:
//         return const SizedBox.shrink();
//     }
//
//     return Positioned.fill(
//       child: IgnorePointer(
//         child: FadeTransition(
//           opacity: fadeAnimation,
//           child: Center(
//             child: Lottie.asset(
//               asset,
//               controller: lottieController,
//               onLoaded: (composition) {
//                 lottieController.duration = composition.duration * 0.5;
//               },
//               fit: BoxFit.contain,
//               repeat: false,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
