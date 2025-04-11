// import 'package:flutter/material.dart';
// import 'dart:math'; // min() 함수 사용을 위해 추가
//
// import '../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
//
// class MPInputList extends StatefulWidget {
//   final int itemCount; // 몇 개의 HandwritingRecognitionZone을 띄울지
//   final Function(List<String>)? onAllRecognized; // 상위로 인식 결과 전달 콜백 (옵션)
//   final List<GlobalKey<HandwritingRecognitionZoneState>> recognitionZoneKeys;
//
//   const MPInputList({
//     Key? key,
//     required this.itemCount,
//     required this.recognitionZoneKeys, // GlobalKey 리스트를 받아서 상태 관리
//     this.onAllRecognized,
//   }) : super(key: key);
//
//   @override
//   State<MPInputList> createState() => _MPInputListState();
// }
//
// class _MPInputListState extends State<MPInputList> {
//   late List<String> recognizedResults;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // 🔹 리스트 길이 검증: itemCount와 recognitionZoneKeys 길이 맞추기
//     int validItemCount = min(widget.itemCount, widget.recognitionZoneKeys.length);
//
//     recognizedResults = List.filled(validItemCount, ''); // 빈 문자열 리스트로 초기화
//   }
//
//   void _onRecognitionChanged(int index, String recognizedText) {
//     setState(() {
//       recognizedResults[index] = recognizedText; // 해당 index의 값 업데이트
//     });
//
//     // 모든 인식 결과를 상위 위젯으로 전달
//     if (widget.onAllRecognized != null) {
//       widget.onAllRecognized!(recognizedResults);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     int validItemCount = min(widget.itemCount, widget.recognitionZoneKeys.length);
//
//     return Column(
//       children: [
//         const SizedBox(height: 20), // 간격 조절
//
//         // HandwritingRecognitionZone 입력 UI
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal, // 가로 스크롤 가능
//           child: Row(
//             children: List.generate(validItemCount, (index) {
//               return Row(
//                 children: [
//                   HandwritingRecognitionZone(
//                     key: widget.recognitionZoneKeys[index], // GlobalKey 사용
//                     width: 135,
//                     height: 135,
//                     backgroundColor: Colors.white54,
//                     strokeColor: Colors.black,
//                     strokeWidth: 3.0,
//                     onRecognized: (recognizedText) {
//                       _onRecognitionChanged(index, recognizedText);
//                     },
//                   ),
//                   if (index < validItemCount - 1) const SizedBox(width: 15),
//                 ],
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
// }
