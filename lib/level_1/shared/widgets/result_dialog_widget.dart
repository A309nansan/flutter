import 'package:flutter/material.dart';

class ResultDialogWidget extends StatelessWidget {
  final bool isCorrect;
  final int? elapsedSeconds;
  final VoidCallback onConfirmPressed;

  const ResultDialogWidget({
    super.key,
    required this.isCorrect,
    required this.elapsedSeconds,
    required this.onConfirmPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isCorrect ? '완벽해요!' : '다시 확인해주세요!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isCorrect ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            isCorrect ? '모든 정답을 찾았어요!' : '다시 시도해보세요!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text('소요 시간: ${elapsedSeconds ?? 0}초', textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmPressed();
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}
