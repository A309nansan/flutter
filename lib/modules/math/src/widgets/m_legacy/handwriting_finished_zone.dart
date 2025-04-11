// import 'package:flutter/material.dart';
//
// class HandwritingFinishedZone extends StatelessWidget {
//   final String recognizedText;
//   final VoidCallback onErase;
//
//   const HandwritingFinishedZone({
//     super.key,
//     required this.recognizedText,
//     required this.onErase,
//     required double width,
//     required double height,
//   });
//c
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // 적당한 크기로 조정 가능
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             '인식된 숫자: $recognizedText',
//             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           ElevatedButton(onPressed: onErase, child: const Text('다시 쓰기')),
//         ],
//       ),
//     );
//   }
// }
