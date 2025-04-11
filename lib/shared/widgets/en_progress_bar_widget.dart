import 'package:flutter/material.dart';

class EnProgressBarWidget extends StatelessWidget {
  final int current;
  final int total;

  const EnProgressBarWidget({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          current == total ? "마지막 문제예요!" : "앞으로 ${total - current}문제 남았어요!",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.025,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.015,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                offset: const Offset(2, 2),
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: current == total ? Colors.lightBlue : Colors.greenAccent,
            ),
          ),
        ),
      ],
    );
  }
}
