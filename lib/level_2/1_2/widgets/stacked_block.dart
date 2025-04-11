import 'package:flutter/material.dart';
import 'package:nansan_flutter/level_2/1_2/widgets/rect_box.dart';

class StackedBlock extends StatelessWidget {
  final int number;
  final bool isSelected;
  final bool isWrong;
  final bool isCorrect;
  final AnimationController controller;
  final VoidCallback? onPressed;

  const StackedBlock({
    super.key,
    required this.number,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 1. 전체 블록 수만큼 리스트 생성
    final blocks = List.generate(number, (_) => const RectBox(
      width: 60,
      height: 60,
      color: Colors.blueAccent,
    ));

    // 2. 한 줄에 최대 10개씩 나누기
    final chunked = <List<Widget>>[];
    for (int i = 0; i < blocks.length; i += 10) {
      chunked.add(blocks.sublist(
        i,
        i + 10 > blocks.length ? blocks.length : i + 10,
      ));
    }

    return Stack(
      children: [
        SizedBox(
          height: screenHeight * 0.2,
          width: screenWidth * 0.85,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromARGB(255, 249, 241, 196),
              disabledBackgroundColor: Colors.white,
              shape: isSelected
                  ? RoundedRectangleBorder(
                side: const BorderSide(width: 4.5, color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              )
                  : RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              elevation: 3,
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...chunked.map((row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: row,
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
