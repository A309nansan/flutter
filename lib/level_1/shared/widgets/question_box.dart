import 'package:flutter/material.dart';

class QuestionBox extends StatefulWidget {
  final String imageText;
  final List<String> options;
  final String correctAnswer;
  final int questionId;
  final Function(int, String) onAnswerSelected;
  final String? selectedAnswer;

  const QuestionBox({
    super.key,
    required this.imageText,
    required this.options,
    required this.correctAnswer,
    required this.questionId,
    required this.onAnswerSelected,
    this.selectedAnswer,
  });

  @override
  State createState() => _QuestionBoxState();
}

class _QuestionBoxState extends State<QuestionBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 330,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.lightBlue, width: 2),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            alignment: Alignment.center,
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Image.network(widget.imageText),
          ),
          const SizedBox(height: 20),
          Container(
            width: 280,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  widget.options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: InkWell(
                        onTap: () {
                          widget.onAnswerSelected(widget.questionId, option);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 70,
                          height: 50,
                          color:
                              widget.selectedAnswer == option
                                  ? Colors.blue[100]
                                  : null, // 선택된 항목 강조
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight:
                                  widget.selectedAnswer == option
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
