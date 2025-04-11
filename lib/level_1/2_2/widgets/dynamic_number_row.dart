import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class DynamicNumberRow extends StatelessWidget {
  final List<int> data;

  const DynamicNumberRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          data.map((number) {
            if (number == 0) {
              // 숫자가 0인 경우 HandwritingRecognitionZone 생성
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: HandwritingRecognitionZone(width: 100, height: 100),
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
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              );
            }
          }).toList(),
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
