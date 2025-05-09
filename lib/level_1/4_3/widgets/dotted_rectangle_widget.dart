import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class DottedRectangleWidget extends StatelessWidget {
  final String rowId;
  final List<dynamic> data;
  final Map<String, GlobalKey<HandwritingRecognitionZoneState>> zoneKeys;
  final double screenWidth;

  const DottedRectangleWidget({
    super.key,
    required this.rowId,
    required this.data,
    required this.zoneKeys,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: List.generate(2, (row) {
            return Row(
              children: List.generate(5, (col) {
                int index = row * 5 + col;
                Widget? content;
                if (index < data[1]) {
                  content = Container(
                    width: screenWidth * 0.04,
                    height: screenWidth * 0.04,
                    decoration: const BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                  );
                } else if (index < data[1] + data[2]) {
                  content = Container(
                    width: screenWidth * 0.04,
                    height: screenWidth * 0.04,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  );
                }

                return Container(
                  width: screenWidth * 0.07,
                  height: screenWidth * 0.07,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  alignment: Alignment.center,
                  child: content,
                );
              }),
            );
          }),
        ),


        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(builder: (context) {
                final key = '$rowId-0';
                zoneKeys.putIfAbsent(
                  key,
                      () => GlobalKey<HandwritingRecognitionZoneState>(),
                );
                final zoneKey = zoneKeys[key]!;
                return HandwritingRecognitionZone(
                  key: zoneKey,
                  width: screenWidth * 0.1,
                  height: screenWidth * 0.1,
                );
              }),

              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: 0.6,
                    child: const Icon(Icons.arrow_downward, size: 36),
                  ),
                  SizedBox(width: screenWidth * 0.06),
                  Transform.rotate(
                    angle: -0.6,
                    child: const Icon(Icons.arrow_downward, size: 36),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(builder: (context) {
                    final key = '$rowId-1';
                    zoneKeys.putIfAbsent(
                      key,
                          () => GlobalKey<HandwritingRecognitionZoneState>(),
                    );
                    final zoneKey = zoneKeys[key]!;
                    return HandwritingRecognitionZone(
                      key: zoneKey,
                      width: screenWidth * 0.1,
                      height: screenWidth * 0.1,
                      borderColor: Colors.pink,
                    );
                  }),
                  SizedBox(width: screenWidth * 0.05),
                  Builder(builder: (context) {
                    final key = '$rowId-2';
                    zoneKeys.putIfAbsent(
                      key,
                          () => GlobalKey<HandwritingRecognitionZoneState>(),
                    );
                    final zoneKey = zoneKeys[key]!;
                    return HandwritingRecognitionZone(
                      key: zoneKey,
                      width: screenWidth * 0.1,
                      height: screenWidth * 0.1,
                      borderColor: Colors.green,
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}