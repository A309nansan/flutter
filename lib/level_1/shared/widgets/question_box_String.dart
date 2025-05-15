import 'package:flutter/material.dart';

class QuestionBoxString extends StatefulWidget {
  final double width;
  final double height;
  final List<String> options;
  final int questionId;
  final Function(int, String) onAnswerSelected;
  final String? selectedAnswer;
  final int number;
  final String object;

  const QuestionBoxString({
    super.key,
    required this.width,
    required this.height,
    required this.options,
    required this.questionId,
    required this.onAnswerSelected,
    required this.number,
    required this.object,
    this.selectedAnswer,
  });

  @override
  State createState() => _QuestionBoxStringState();
}

class _QuestionBoxStringState extends State<QuestionBoxString> {
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
            child: Image.asset('assets/images/number/${widget.object}/${widget.number}.png'),
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
              children: widget.options.map((option) {
                bool isSelected = widget.selectedAnswer == option.toString()  ;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      widget.onAnswerSelected(widget.questionId, option);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: widget.width * 0.1,
                      height: widget.height * 0.05,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[100] : null,
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: widget.width * 0.05,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
