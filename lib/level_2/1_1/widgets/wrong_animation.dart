import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WrongAnimation extends StatelessWidget{
  const WrongAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        "assets/lottie/cross_mark_animation.json",
        repeat: false,
        width: 450,
        height: 450,
      ),
    );
  }
}