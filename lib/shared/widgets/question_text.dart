import 'package:flutter/material.dart';

class QuestionTextWidget extends StatelessWidget {
  final String questionText;

  const QuestionTextWidget({super.key, required this.questionText});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            color: Colors.blue,
            margin: EdgeInsets.only(top: screenHeight * 0.003),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(questionText, style: TextStyle(fontSize: screenWidth * 0.02)),
          ),
        ],
      ),
    );
  }
}
