import 'package:flutter/material.dart';
import 'package:nansan_flutter/level_1/1_1/models/answer_candidate.dart';

class AnswerGridItemWidget extends StatelessWidget {
  final AnswerCandidate candidate;
  final List<String?> selectedAnswers;
  final Function(String?) onSelectionChanged;

  const AnswerGridItemWidget({
    super.key,
    required this.candidate,
    required this.selectedAnswers,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedAnswers.contains(candidate.key);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth * 0.9;
        final double height = constraints.maxHeight * 0.9;

        return ElevatedButton(
          onPressed: () => onSelectionChanged(candidate.key),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 4,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 10,
              ),
            ),
          ),
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/number/${candidate.object}/${candidate.number}.png',
              fit: BoxFit.contain,
              width: width,
              height: height,
            ),
          ),
        );
      },
    );
  }
}
