import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class DynamicNumberRow extends StatelessWidget {
  final String rowId;
  final List<int> data;
  final Map<String, GlobalKey<HandwritingRecognitionZoneState>> zoneKeys;

  const DynamicNumberRow({
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
          // 숫자가 0인 경우 HandwritingRecognitionZone 생성
          final key = '$rowId-$index';
          zoneKeys.putIfAbsent(key, () => GlobalKey<HandwritingRecognitionZoneState>());
          final zoneKey = zoneKeys[key]!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: HandwritingRecognitionZone(
              key: zoneKey,
              width: 100,
              height: 100,
            ),
          );
        } else {
          // 숫자가 0이 아닌 경우 해당 숫자를 포함하는 Container 생성
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              width: 100,
              height: 100,
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


// data.map((number) {
//             if (number == 0) {
//               // 숫자가 0인 경우 HandwritingRecognitionZone 생성
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: HandwritingRecognitionZone(width: 100, height: 100),
//               );
//             } else {
//               // 숫자가 0이 아닌 경우 해당 숫자를 포함하는 Container 생성
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Container(
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black, width: 1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   width: 100,
//                   height: 100,
//                   child: Text(
//                     number.toString(),
//                     style: TextStyle(fontSize: 60),
//                   ),
//                 ),
//               );
//             }
//           }).toList(),
