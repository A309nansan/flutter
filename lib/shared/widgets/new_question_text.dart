import 'package:flutter/material.dart';

class NewQuestionTextWidget extends StatelessWidget {
  final String questionText;
  final double? questionTextSize;

  const NewQuestionTextWidget({super.key, required this.questionText, this.questionTextSize});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: screenWidth * 0.025,
            height: screenWidth * 0.025,
            color: Colors.blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              questionText,
              style: TextStyle(
                fontSize: questionTextSize ?? screenWidth * 0.02,
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ],
      ),
    );
  }
}
