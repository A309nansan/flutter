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
    final isSelected = selectedAnswers.contains(candidate.key); // 키 기반 선택 확인

    return GestureDetector(
      onTap: () => onSelectionChanged(candidate.key),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : null,
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.285,
                height: MediaQuery.of(context).size.height * 0.185,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.lightBlue[100] : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Image.network(
                    candidate.imageUrl ?? '', // 기본값으로 빈 문자열 사용
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, color: Colors.red);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
