import 'package:flutter/material.dart';
import 'package:nansan_flutter/level_1/2_3/widgets/line_painter.dart';

class NumberSelectionWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final List<int> numberList;
  final int givenNumber;
  final int? selectedIndex;
  final Function(int index, String selectedButton) onSelect;

  const NumberSelectionWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.numberList,
    required this.givenNumber,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final contents = [
      numberList[0],
      'left',
      numberList[1],
      'right',
      numberList[2],
    ];

    return Column(
      children: [
        SizedBox(
          width: screenWidth * 0.75,
          height: screenHeight * 0.07,
          child: GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            childAspectRatio: 1.5,
            children: List.generate(5, (index) {
              final isSelectable = contents[index] == 'left' || contents[index] == 'right';
              final isSelected = selectedIndex == index;

              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: screenWidth * 0.15,
                    height: screenHeight * 0.1,
                    child: ElevatedButton(
                      onPressed: isSelectable
                          ? () {
                        final btn = contents[index].toString();
                        onSelect(index, btn);
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFef1c4),
                        foregroundColor: Colors.black,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: const BorderSide(color: Color(0xFF9c6a17)),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        disabledBackgroundColor: const Color(0xFFFef1c4),
                        disabledForegroundColor: Colors.black,
                      ),
                      child: contents[index] is int
                          ? Text(
                        '${contents[index]}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      child: IgnorePointer(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
        SizedBox(
          width: screenWidth * 0.75,
          height: screenHeight * 0.1,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(screenWidth * 0.75, screenHeight * 0.1),
                painter: LinePainter(
                  start: Offset(screenWidth * 0.75 * 0.3, 0),
                  end: Offset(screenWidth * 0.75 * 0.5, screenHeight * 0.1),
                ),
              ),
              CustomPaint(
                size: Size(screenWidth * 0.75, screenHeight * 0.1),
                painter: LinePainter(
                  start: Offset(screenWidth * 0.75 * 0.5, screenHeight * 0.1),
                  end: Offset(screenWidth * 0.75 * 0.7, 0),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          child: Container(
            height: screenHeight * 0.06,
            width: screenWidth * 0.15,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFef1c4),
              border: Border.all(color: const Color(0xFF9c6a17)),
            ),
            child: Center(
              child: Text(
                '$givenNumber',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}