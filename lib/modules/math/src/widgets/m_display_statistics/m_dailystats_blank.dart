import 'package:flutter/material.dart';

class MDailyStatsBlank extends StatelessWidget {
  const MDailyStatsBlank({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.5, // 0.0 ~ 1.0 사이 값 (낮을수록 더 투명해짐)
            child: Image.asset(
              'assets/images/basa_math/nothing_here.png',
              width: 500,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "이 날은 푼 문제가 없어요.",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
