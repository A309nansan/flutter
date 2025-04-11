import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class RedBlueTenProblem extends StatelessWidget {
  final int index;
  final int first;
  final int second;
  final bool isChecked;
  final VoidCallback setIsChecked;
  final GlobalKey<HandwritingRecognitionZoneState> firstKey;
  final GlobalKey<HandwritingRecognitionZoneState> secondKey;
  final bool? result;
  final VoidCallback onClear;

  const RedBlueTenProblem({
    super.key,
    required this.index,
    required this.first,
    required this.second,
    required this.isChecked,
    required this.setIsChecked,
    required this.firstKey,
    required this.secondKey,
    this.result,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            Container(
              height: screenHeight * 0.24,
              width: screenWidth * 0.9,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
                childAspectRatio: 1,
                children: List.generate(10, (idx) {
                  Color color = Colors.grey[300]!;
                  if (idx < first) {
                    color = Colors.redAccent;
                  } else if (idx < first + second) {
                    color = Colors.blueAccent;
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 25),
        Center(
          child: SizedBox(
            width: screenWidth * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth * 0.1,
                  child: IconButton(
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.restart_alt_rounded,
                      size: 40,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: screenWidth * 0.3,
                      padding: const EdgeInsets.only(left: 30),
                      child: HandwritingRecognitionZone(
                        key: firstKey,
                        width: 200,
                        height: 200,
                        backgroundColor: Colors.grey.shade100,
                        borderColor: Colors.redAccent,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      left: 0,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 5),
                Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: screenWidth * 0.3,
                      padding: const EdgeInsets.only(right: 30),
                      child: HandwritingRecognitionZone(
                        key: secondKey,
                        width: 200,
                        height: 200,
                        backgroundColor: Colors.grey.shade100,
                        borderColor: Colors.blueAccent,
                      ),
                    ),
                    Positioned(
                      top: 1,
                      right: 0,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 50),
        const SizedBox(height: 30),
      ],
    );
  }
}
