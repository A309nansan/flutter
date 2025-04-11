// import 'package:flutter/material.dart';
//
// import '../../../../../shared/digit_recognition/widgets/recognition_button.dart';
// import '../m_index_presenter.dart';
// import '../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
//
// class MProblemHeader extends StatelessWidget {
//   final int problemIndex;
//   final List<GlobalKey<HandwritingRecognitionZoneState>> recognitionZoneKeysSum;
//   final VoidCallback onRecognitionComplete;
//   final VoidCallback onClear;
//
//   const MProblemHeader({
//     Key? key,
//     required this.problemIndex,
//     required this.recognitionZoneKeysSum,
//     required this.onRecognitionComplete,
//     required this.onClear,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IndexPresenter(indexLabel: problemIndex),
//         const SizedBox(width: 400),
//         Transform.scale(
//           scale: 1.5,
//           child: RecognitionButton(
//             recognitionZoneKeys: recognitionZoneKeysSum,
//             buttonText: '🧐',
//             onRecognitionComplete: onRecognitionComplete,
//           ),
//         ),
//         const SizedBox(width: 40),
//         ElevatedButton(
//           onPressed: onClear,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.white24,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             textStyle: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           child: const Text('❌'),
//         ),
//       ],
//     );
//   }
// }