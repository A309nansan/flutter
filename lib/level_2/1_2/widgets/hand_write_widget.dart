import 'package:flutter/material.dart';
import '../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class HandWriteWidget extends StatelessWidget {
  final int index;
  final int number;
  final String numberText;
  final GlobalKey<HandwritingRecognitionZoneState> tenKey;
  final GlobalKey<HandwritingRecognitionZoneState> oneKey;

  final bool? result;
  final VoidCallback onClear;
  final VoidCallback onRecognitionComplete;

  const HandWriteWidget({
    super.key,
    required this.index,
    required this.number,
    required this.numberText,
    required this.tenKey,
    required this.oneKey,
    this.result,
    required this.onClear,
    required this.onRecognitionComplete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: screenHeight * 0.16,
          width: screenWidth * 0.3,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "$number",
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 10,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.record_voice_over_rounded,
                    size: 30,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    numberText,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  "십의 자리",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                HandwritingRecognitionZone(
                  key: tenKey,
                  width: screenHeight * 0.13,
                  height: screenHeight * 0.13,
                ),
              ],
            ),
            const SizedBox(width: 5),
            Column(
              children: [
                Text(
                  "일의 자리",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                HandwritingRecognitionZone(
                  key: oneKey,
                  width: screenHeight * 0.13,
                  height: screenHeight * 0.13,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
