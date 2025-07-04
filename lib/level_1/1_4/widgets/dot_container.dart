import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class DotContainer extends StatelessWidget {
  final int ans;
  final GlobalKey<HandwritingRecognitionZoneState>? zoneKey;

  const DotContainer({
    super.key,
    required this.ans,
    this.zoneKey,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final dotCount = ans * 2;
    final dotSize = screenHeight * 0.045;

    // 도트가 채워질 행과 열 수 결정
    final columns = sqrt(dotCount).ceil();
    final rows = (dotCount / columns).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      width: screenWidth * 0.8,
      height: screenHeight * 0.23,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            blurRadius: 3,
            offset: const Offset(1, 2),
          ),
        ],
        // border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.32,
            // color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(rows, (row) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(columns, (col) {
                    final index = row * columns + col;
                    if (index >= dotCount) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(77),
                              blurRadius: 3,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
          SizedBox(width: screenWidth * 0.08),
          // 원래 있던 부분
          if (zoneKey != null)
            HandwritingRecognitionZone(
              key: zoneKey,
              width: screenWidth * 0.25,
              height: screenWidth * 0.25,
              strokeWidth: 4,
            )
          else
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              width: 100,
              height: 100,
              child: Text(
                (ans * 2).toString(),
                style: const TextStyle(fontSize: 60),
              ),
            ),
        ],
      ),
    );
  }
}
