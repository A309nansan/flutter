import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class QuestionBox extends StatefulWidget {
  final double width;
  final double height;
  final List<int> options;
  final int questionId;
  final Function(int, int?) onAnswerSelected;
  final int? selectedAnswer;
  final int number;
  final String object;

  const QuestionBox({
    super.key,
    required this.width,
    required this.height,
    required this.options,
    required this.questionId,
    required this.onAnswerSelected,
    required this.number,
    required this.object,
    required this.selectedAnswer,
  });

  @override
  State createState() => _QuestionBoxState();
}

class _QuestionBoxState extends State<QuestionBox> {
  int? value;

  @override
  void initState() {
    super.initState();
    value = null;
  }

  void onChanged(int? i) {
    setState(() {
      value = i;
    });
    widget.onAnswerSelected(widget.questionId, i);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width * 0.43,
      height: widget.height * 0.32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/images/number/${widget.object}/${widget.number}.png',
            ),
          ),
          SizedBox(
            width: widget.width * 0.4,
            height: widget.height * 0.07,
            child: AnimatedToggleSwitch<int?>.size(
              current: value,
              values: [...widget.options],
              allowUnlistedValues: true,
              iconOpacity: 1.0,
              indicatorSize: Size.fromWidth(widget.width * 0.14),
              iconAnimationType: AnimationType.onSelected,
              borderWidth: 5.0,
              style: ToggleStyle(
                borderColor: Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              styleBuilder: (i) => ToggleStyle(
                indicatorColor: Colors.lightBlue,
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              iconBuilder: (i) {
                bool isSelected = value != null && i == value;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${i ?? ""}',
                    style: TextStyle(
                      fontSize: widget.width * 0.035,
                      fontWeight:FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black38,
                    ),
                  ),
                );
              },
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
