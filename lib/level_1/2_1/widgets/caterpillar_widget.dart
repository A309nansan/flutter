import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class CaterpillarWidget extends StatelessWidget {
  final String rowId;
  final List<dynamic> data;
  final Map<String, GlobalKey<HandwritingRecognitionZoneState>> zoneKeys;

  const CaterpillarWidget({
    super.key,
    required this.rowId,
    required this.data,
    required this.zoneKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(data.length, (index) {
        final number = data[index];

        if (number == 0) {
          // For 0, create a handwriting input zone with circular shape
          final key = '$rowId-$index';
          zoneKeys.putIfAbsent(key, () => GlobalKey<HandwritingRecognitionZoneState>());
          final zoneKey = zoneKeys[key]!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipOval(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: HandwritingRecognitionZone(
                  key: zoneKey,
                  width: 100,
                  height: 100,
                  borderColor: Colors.white10,
                ),
              ),
            ),
          );
        } else {
          // For non-zero numbers, display in a circular container
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Text(
                number.toString(),
                style: const TextStyle(fontSize: 60),
              ),
            ),
          );
        }
      }),
    );
  }
}
