import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessfulPopup extends StatelessWidget {
  final Animation<double> scaleAnimation;

  const SuccessfulPopup({
    super.key,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(3, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/success_bunny_${Random().nextInt(4) + 1}.png",
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "모두 맞췄어요!",
                    style: TextStyle(
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Lottie.asset(
                'assets/lottie/confetti.json',
                fit: BoxFit.contain,
                // repeat: false,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
