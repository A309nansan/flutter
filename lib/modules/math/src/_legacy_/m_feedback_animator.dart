// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
//
// import '../screens/m_lecture_screen.dart';
// import 'm_feedback_animator_unit.dart';
//
// class FeedbackAnimatorWidget extends StatefulWidget {
//   final EvaluationStatus status;
//
//   const FeedbackAnimatorWidget({
//     Key? key,
//     required this.status,
//   }) : super(key: key);
//
//   @override
//   State<FeedbackAnimatorWidget> createState() => _FeedbackAnimatorWidgetState();
// }
//
// class _FeedbackAnimatorWidgetState extends State<FeedbackAnimatorWidget> with TickerProviderStateMixin {
//   late final FeedbackAnimator _animator;
//
//   @override
//   void initState() {
//     super.initState();
//     _animator = FeedbackAnimator(vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _animator.play();
//     });
//   }
//
//   @override
//   void didUpdateWidget(covariant FeedbackAnimatorWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.status != widget.status) {
//       _animator.play();
//     }
//   }
//
//   @override
//   void dispose() {
//     _animator.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _animator.build(isCorrect: widget.status);
//   }
// }
