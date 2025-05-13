import 'package:flutter/material.dart';

class QuestionBox extends StatefulWidget {
  final double width;
  final double height;
  final String imageText;
  final List<String> options;
  //final List<int> options;
  final String correctAnswer;
  final int questionId;
  final Function(int, String) onAnswerSelected;
  // final Function(int, int) onAnswerSelected;
  final String? selectedAnswer;
  //final int number;

  const QuestionBox({
    super.key,
    required this.width,
    required this.height,
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
      width: widget.width * 0.43,
      height: widget.height * 0.32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
        color: Colors.lightBlue[100],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            alignment: Alignment.center,
            width: widget.width * 0.35,
            height: widget.height * 0.22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Image.network(widget.imageText),
            // child: Image.asset('assets/images/number/$object/$number'),
          ),
          Container(
            width: widget.width * 0.38,
            height: widget.height * 0.05,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
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
                          width: widget.width * 0.1,
                          height: widget.height * 0.05,
                          color:
                              widget.selectedAnswer == option
                                  ? Colors.blue[100]
                                  : null, // 선택된 항목 강조
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: widget.width * 0.05,
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
