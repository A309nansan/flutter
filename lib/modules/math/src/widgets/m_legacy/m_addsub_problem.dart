// import 'package:flutter/material.dart';
//
// import '../../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
// import '../../../../../../shared/digit_recognition/widgets/recognition_button.dart';
// import '../../../models/math_paper_model.dart';
// import '../../../utils/math_basic.dart';
// import '../../m_index_presenter.dart';
// import 'mp_input_list.dart';
// import 'mp_present_matrix.dart';
// //LEGACY
// //LEGACY
// //LEGACY
// //LEGACY
// class MAddSubProblem extends StatefulWidget {
//   final MathProblem problemData;
//   final Function(List<List<String>>)? onResultUpdated;
//   final List<List<String>> initialResult;
//   const MAddSubProblem({
//     Key? key,
//     required this.problemData,
//     required this.onResultUpdated,
//     required this.initialResult,
//   }) : super(key : key);
//
//   @override
//   _MAddSubProblemState createState() => _MAddSubProblemState();
//
// }
// //LEGACY
// //LEGACY
// //LEGACY
// //LEGACY
// class _MAddSubProblemState extends State<MAddSubProblem>{
//   late List<GlobalKey<HandwritingRecognitionZoneState>> recognitionZoneKeys;
//   late List<String> recognitionResults;
//   late List<GlobalKey<HandwritingRecognitionZoneState>> recognitionCarryZoneKeys;
//   late List<String> recognitionCarryResults;
//   late List<List<String>> problemToList = formatMathProblem(
//     widget.problemData.num1,
//     widget.problemData.num2,
//     opConvert(widget.problemData.operand),
//     widget.problemData.blankRow);
// //LEGACY
// //LEGACY
// //LEGACY
// //LEGACY
//   @override
//   void initState() {
//     super.initState();
//
//     int blankCount = widget.problemData.blankRow ?? 1; // ✅ 문제의 빈 칸 개수 설정
//     recognitionZoneKeys = List.generate(
//       blankCount,
//           (i) => GlobalKey<HandwritingRecognitionZoneState>(
//           debugLabel: 'problem${widget.problemData.problemIndex}_index$i'
//       ),
//     );
//     recognitionCarryZoneKeys = List.generate(
//       blankCount,
//           (i) => GlobalKey<HandwritingRecognitionZoneState>(
//           debugLabel: 'problem${widget.problemData.problemIndex}_carry_index$i'
//       ),
//     );
//     recognitionResults = List.generate(blankCount, (_) => '');
//     recognitionCarryResults = List.generate(blankCount, (_) => '');
//   }
//   void _clearAll() {
//     int blankCount = widget.problemData.blankRow ?? 1; // ✅ 문제의 빈 칸 개수 설정
//     for (var key in recognitionZoneKeys) {
//       key.currentState?.clear();
//     }
//
//     setState(() {
//       recognitionResults = List.generate(blankCount , (_) => '');
//     });
//
//     for (var key in recognitionCarryZoneKeys) {
//       key.currentState?.clear();
//     }
//     setState(() {
//       recognitionCarryResults = List.generate(blankCount , (_) => '');
//     });
//   }
//   void _updateResults() {
//     List<List<String>> combinedResults = [
//       recognitionCarryResults,
//       recognitionResults,
//       // ✅ 기존 2D 리스트 유지
//       // ✅ CarryResults를 새로운 행으로 추가
//     ];
// //LEGACY
// //LEGACY
// //LEGACY
// //LEGACY
//     // ✅ 콜백이 설정된 경우 호출하여 외부 모듈에 2D 리스트 전달
//     if (widget.onResultUpdated != null) {
//       widget.onResultUpdated!(combinedResults);
//     }
//   }
//   void _onRecognitionComplete() {
//     int blankCount = widget.problemData.blankRow ?? 1;
//     setState(() {
//       // 모든 필기 영역의 인식된 텍스트를 저장
//       for (int i = 0; i < blankCount; i++) {
//         recognitionResults[i] = recognitionZoneKeys[i].currentState?.recognizedText ?? '';
//         recognitionCarryResults[i] = recognitionCarryZoneKeys[i].currentState?.recognizedText ?? '';
//       }
//     });
//     _updateResults();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('모든 영역의 인식이 완료되었습니다')),
//     );
//   }
//
//
// //LEGACY
// //LEGACY
// //LEGACY
// //LEGACY
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center, // 🔹 버튼들도 중앙 정렬
//             children: [
//               IndexPresenter(indexLabel: widget.problemData.problemIndex),
//               const SizedBox(width: 400), // 🔹 간격 조절
//               Transform.scale(
//                 scale: 1.5, // 크기 1.5배 증가 (조절 가능)
//                 child: RecognitionButton(
//                   recognitionZoneKeys: recognitionZoneKeys+ recognitionCarryZoneKeys,
//                   buttonText: '🧐',
//                   onRecognitionComplete: _onRecognitionComplete,
//                 ),
//               ),
//               const SizedBox(width: 40), // 버튼 사이 간격
//               ElevatedButton(
//                 onPressed: _clearAll,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white24,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24), // 🔸 크기 키움
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15), // 🔸 둥글기 줄이기 (기본 20~30보다 작게)
//                   ),
//                   textStyle: const TextStyle(
//                     fontSize: 20, // 🔸 텍스트 크기 키움
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 child: const Text('❌'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 100),
//           Column(
//             children: [
//               MPInputList(
//                 itemCount: widget.problemData.blankRow,
//                 recognitionZoneKeys: recognitionCarryZoneKeys,
//               ),
//               MPPresentMatrix(gridData: problemToList),
//               const SizedBox(height: 10), // 간격 조정
//               Divider(
//                 color: Colors.black, // 선 색상
//                 thickness: 2, // 선 두께
//                 indent: 350, // 좌측 여백
//                 endIndent: 350, // 우측 여백
//
//               ),
//               const SizedBox(height: 10), // 간격 조정
//               MPInputList(
//                 itemCount: widget.problemData.blankRow,
//                 recognitionZoneKeys: recognitionZoneKeys,
//               ),
//             ],
//           ),
//         ],
//       ),
//
//       // 오른쪽 끝에 두 버튼을 가깝게 정
//     );
//   }
// }