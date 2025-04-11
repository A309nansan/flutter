// import 'package:flutter/material.dart';
// import 'package:nansan_flutter/modules/math/src/widgets/mproblem/m_legacy/mp_present_matrix.dart';
//
// import '../../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
// import '../../../../../../shared/digit_recognition/widgets/recognition_button.dart';
// import '../../../models/math_paper_model.dart';
// import '../../../utils/math_basic.dart';
// import '../../m_index_presenter.dart';
// import 'mp_input_list.dart';
// import '../mp_present_matrix_singleline.dart';
//
// class MSinglelineProblem extends StatefulWidget {
//   final MathProblem problemData;
//   final Function(List<List<String>>)? onResultUpdated;
//   final List<List<String>> initialResult;
//
//   const MSinglelineProblem({Key? key, required this.problemData, required this.onResultUpdated, required this.initialResult})
//     : super(key: key);
//
//   @override
//   _MSinglelineProblemState createState() => _MSinglelineProblemState();
// }
//
// class _MSinglelineProblemState extends State<MSinglelineProblem> {
//   late List<GlobalKey<HandwritingRecognitionZoneState>> recognitionZoneKeys;
//   late List<String> recognitionResults;
//   late String problemStr =
//       "${widget.problemData.num1}${opConvert(widget.problemData.operand)}${widget.problemData.num2}=";
//   late List<List<String>> problemToList = [problemStr.split('')];
//
//   @override
//   void initState() {
//     super.initState();
//
//     int blankCount = widget.problemData.blankRow ?? 1; // ✅ 문제의 빈 칸 개수 설정
//     recognitionZoneKeys = List.generate(
//       blankCount,
//       (i) => GlobalKey<HandwritingRecognitionZoneState>(
//         debugLabel: 'problem${widget.problemData.problemIndex}_index$i',
//       ),
//     );
//
//     recognitionResults = List.generate(blankCount, (_) => '');
//   }
//
//   void _clearAll() {
//     for (var key in recognitionZoneKeys) {
//       key.currentState?.clear();
//     }
//
//     setState(() {
//       recognitionResults = List.generate(3, (_) => '');
//     });
//   }
//   void _updateResults() {
//   List<List<String>> combinedResults = [recognitionResults];    // ✅ 콜백이 설정된 경우 호출하여 외부 모듈에 2D 리스트 전달
//   if (widget.onResultUpdated != null) {
//     widget.onResultUpdated!(combinedResults);
//   }
//
//   }
//   void _onRecognitionComplete() {
//     int blankCount = widget.problemData.blankRow ?? 1;
//     setState(() {
//       // 모든 필기 영역의 인식된 텍스트를 저장
//       for (int i = 0; i < blankCount; i++) {
//         recognitionResults[i] =
//             recognitionZoneKeys[i].currentState?.recognizedText ?? '';
//       }
//     });
//     _updateResults();
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('모든 영역의 인식이 완료되었습니다')));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center( // 🔹 전체 Column을 중앙 정렬
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center, // 🔹 세로 방향으로 중앙 정렬
//         crossAxisAlignment: CrossAxisAlignment.center, // 🔹 가로 방향 중앙 정렬
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center, // 🔹 버튼들도 중앙 정렬
//             children: [
//               IndexPresenter(indexLabel: widget.problemData.problemIndex),
//               const SizedBox(width: 400), // 🔹 간격 조절
//               Transform.scale(
//                 scale: 1.5, // 크기 1.5배 증가 (조절 가능)
//                 child: RecognitionButton(
//                   recognitionZoneKeys: recognitionZoneKeys,
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
//           const SizedBox(height: 40), // 🔹 간격 조절
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center, // 🔹 버튼들도 중앙 정렬
//             children:[
//               MPPresentMatrixSingleline(gridData: problemToList), // 🔹 수식 표현 부분
//               const SizedBox(width: 50), // 🔹 간격 조절
//               MPInputList(
//                 itemCount: widget.problemData.blankRow,
//                 recognitionZoneKeys: recognitionZoneKeys,
//               ),
//             ]
//           )
//
//         ],
//       ),
//     );
//   }
// }
//
