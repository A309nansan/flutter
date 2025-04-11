// import 'package:flutter/material.dart';
//
// import '../../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
// import '../../../../../../shared/digit_recognition/widgets/recognition_button.dart';
// import '../../../models/math_paper_model.dart';
// import '../../../utils/math_basic.dart';
// import '../../m_index_presenter.dart';
// import 'mp_input_list.dart';
// import 'mp_present_matrix.dart';
//
// class MMultProblem extends StatefulWidget {
//   final MathProblem problemData;
//   final Function(List<List<String>>)? onResultUpdated;
//   final List<List<String>> initialResult;
//   const MMultProblem({
//     Key? key,
//     required this.problemData,
//     required this.onResultUpdated,
//     required this.initialResult
//   }) : super(key: key);
//
//   @override
//   _MMultProblemState createState() => _MMultProblemState();
// }
//
// class _MMultProblemState extends State<MMultProblem> {
//   late List<List<GlobalKey<HandwritingRecognitionZoneState>>> recognitionZoneKeys;
//   late List<GlobalKey<HandwritingRecognitionZoneState>> recognitionCarryZoneKeys;
//   late List<List<String>> recognitionResults;
//   late List<String> recognitionCarryResults;
//   late List<List<String>> problemToList = formatMathProblem(
//     widget.problemData.num1,
//     widget.problemData.num2,
//     opConvert(widget.problemData.operand),
//     widget.problemData.blankRow,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//
//
//     int colCount = widget.problemData.blankColumn;
//     int rowCount = widget.problemData.blankRow;
//
//     recognitionZoneKeys = List.generate(
//       colCount,
//           (i) => List.generate(
//         rowCount,
//             (j) => GlobalKey<HandwritingRecognitionZoneState>(
//           debugLabel: 'problem${widget.problemData.problemIndex}_col${i}_row${j}',
//         ),
//       ),
//     );
//     recognitionCarryZoneKeys = List.generate(
//       rowCount,
//           (i) => GlobalKey<HandwritingRecognitionZoneState>(
//           debugLabel: 'problem${widget.problemData.problemIndex}_carry_index$i'
//       ),
//     );
//     recognitionResults = List.generate(colCount, (_) => List.generate(rowCount, (_) => ''));
//     recognitionCarryResults = List.generate(rowCount, (_) => '');
//   }
//
//   void _clearAll() {
//     for (var col in recognitionZoneKeys) {
//       for (var key in col) {
//         key.currentState?.clear();
//       }
//     }
//     for (var key in recognitionCarryZoneKeys){
//       key.currentState?.clear();
//     }
//     setState(() {
//       recognitionResults = List.generate(
//         recognitionZoneKeys.length,
//             (_) => List.generate(recognitionZoneKeys[0].length, (_) => ''),
//       );
//
//       recognitionCarryResults = List.generate(recognitionCarryResults.length , (_) => '');
//     });
//   }
//   // ✅ 외부로 결과를 전달하는 함수
//   void _updateResults() {
//     List<List<String>> combinedResults = [
//       recognitionCarryResults,
//       ...recognitionResults,
//       // ✅ 기존 2D 리스트 유지
//       // ✅ CarryResults를 새로운 행으로 추가
//     ];
//
//     // ✅ 콜백이 설정된 경우 호출하여 외부 모듈에 2D 리스트 전달
//     if (widget.onResultUpdated != null) {
//       widget.onResultUpdated!(combinedResults);
//     }
//   }
//   void _onRecognitionComplete() {
//     int colCount = recognitionZoneKeys.length;
//     int rowCount = recognitionZoneKeys[0].length;
//
//     setState(() {
//       for (int i = 0; i < colCount; i++) {
//         for (int j = 0; j < rowCount; j++) {
//           recognitionResults[i][j] =
//               recognitionZoneKeys[i][j].currentState?.recognizedText ?? '';
//         }
//       }
//       for(int i = 0; i < rowCount; i++) {
//         recognitionCarryResults[i] = recognitionCarryZoneKeys[i].currentState?.recognizedText ?? '';
//       }
//     });
//     _updateResults();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('모든 영역의 인식이 완료되었습니다')),
//     );
//   }
//
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
//                   recognitionZoneKeys: recognitionZoneKeys.expand((row) => row).toList() + recognitionCarryZoneKeys,
//                   buttonText: '🧐',
//                   buttonColor: Colors.red,
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
//               for (int i = 0; i < recognitionZoneKeys.length; i++) ...[
//                 MPInputList(
//                   itemCount: recognitionZoneKeys[i].length,
//                   recognitionZoneKeys: recognitionZoneKeys[i],
//                 ),
//                 if (i < recognitionZoneKeys.length - 1) const SizedBox(height: 10),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
