// import 'package:flutter/material.dart';
// import '../../../../../../shared/digit_recognition/widgets/recognition_button.dart';
// import '../../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
// import '../../../models/m_problem_metadata.dart';
// import '../../../models/math_paper_model.dart';
// import '../../../utils/math_basic.dart';
// import '../../../utils/math_recognizer.dart';
// import '../../m_index_presenter.dart';
// import '../../../services/m_response.dart';
// import 'announcement.dart';
// import 'm_mult_problem.dart';
// import '../m_problem_addsub.dart';
// import '../m_problem_div.dart';
// import '../m_problem_div_remainder.dart';
// import '../m_problem_mult.dart';
// import '../m_problem_singleline.dart';
// import 'mp_input_list.dart';
// import 'mp_present_matrix.dart';
// import 'm_singleline_problem.dart';
// import 'm_addsub_problem.dart';
// import '../mp_present_matrix_answer.dart';
// import '../mp_present_matrix_response.dart';
//
// class MProblemPracticeLegacy extends StatefulWidget {
//   final MathData mathData;
//   final bool isTest;
//   final List<List<List<String>>> initialResults;
//   final Function(List<List<List<String>>>) onResultsUpdated;
//   final List<List<List<String>>> answer;
//   const MProblemPracticeLegacy({
//     Key? key,
//     required this.mathData,
//     required this.isTest,
//     required this.initialResults,
//     required this.onResultsUpdated,
//     required this.answer,
//   }) : super(key: key);
//
//   @override
//   _MProblemPracticeLegacyState createState() => _MProblemPracticeLegacyState();
// }
//
// class _MProblemPracticeLegacyState extends State<MProblemPracticeLegacy> {
//   bool _isAnswerVisible = false; // ✅ 정답 표시 여부 상태 관리
//
//   int get number1 => widget.mathData.num1;
//   int get number2 => widget.mathData.num2;
//   bool get isOneDigit => widget.mathData.type == "SingleLine";
//   bool get isAddSub => widget.mathData.type == "AddSub";
//   bool get isMultiplication => widget.mathData.type == "Multiplication";
//   bool get isDivision => widget.mathData.type == "Division";
//   bool get isDivisionRemainder => widget.mathData.type == "DivisionRemainder";
//
//   List<List<GlobalKey<HandwritingRecognitionZoneState>>>
//   recognitionProgressZoneKeys = [];
//   List<List<GlobalKey<HandwritingRecognitionZoneState>>>
//   recognitionCarryZoneKeys = [];
//   List<List<GlobalKey<HandwritingRecognitionZoneState>>>
//   recognitionAnswerZoneKeys = [];
//
//   List<List<String>> recognitionProgressResults = [];
//   List<List<String>> recognitionCarryResults = [];
//   List<List<String>> recognitionAnswerResults = [];
//   List<List<List<String>>> recognitionTotalResults = [];
//
//
//   void _initRecognitionKeys(List<int> matrixVolume) {
//     if (recognitionAnswerZoneKeys.isNotEmpty) {
//       recognitionCarryResults = widget.initialResults[0]; // 초기 결과 복사
//       recognitionProgressResults = widget.initialResults[1]; // 초기 결과 복사
//       recognitionAnswerResults = widget.initialResults[2]; // 초기 결과 복사
//     } else {
//       recognitionCarryZoneKeys = generateGlobalKey2D(
//         matrixVolume[0],
//         matrixVolume[1],
//         "carry",
//       );
//       recognitionProgressZoneKeys = generateGlobalKey2D(
//         matrixVolume[2],
//         matrixVolume[3],
//         "progress",
//       );
//       recognitionAnswerZoneKeys = generateGlobalKey2D(
//         matrixVolume[4],
//         matrixVolume[5],
//         "answer",
//       );
//
//       recognitionCarryResults = List.generate(
//         matrixVolume[0],
//         (_) => List.generate(matrixVolume[1], (_) => ''),
//       );
//       recognitionProgressResults = List.generate(
//         matrixVolume[2],
//         (_) => List.generate(matrixVolume[3], (_) => ''),
//       );
//       recognitionAnswerResults = List.generate(
//         matrixVolume[4],
//         (_) => List.generate(matrixVolume[5], (_) => ''),
//       );
//     }
//   }
//
//   void setResults(String type) {
//     if (type == "carry") {
//       for (int i = 0; i < widget.mathData.matrixVolume[0]; i++) {
//         for (int j = 0; j < widget.mathData.matrixVolume[1]; j++) {
//           recognitionCarryResults[i][j] =
//               recognitionCarryZoneKeys[i][j].currentState?.recognizedText ?? '';
//         }
//       }
//     }
//     if (type == "progress") {
//       for (int i = 0; i < widget.mathData.matrixVolume[2]; i++) {
//         for (int j = 0; j < widget.mathData.matrixVolume[3]; j++) {
//           recognitionProgressResults[i][j] =
//               recognitionProgressZoneKeys[i][j].currentState?.recognizedText ??
//               '';
//         }
//       }
//     }
//     if (type == "answer") {
//       for (int i = 0; i < widget.mathData.matrixVolume[4]; i++) {
//         for (int j = 0; j < widget.mathData.matrixVolume[5]; j++) {
//           recognitionAnswerResults[i][j] =
//               recognitionAnswerZoneKeys[i][j].currentState?.recognizedText ??
//               '';
//         }
//       }
//     }
//   }
//
//
//   bool findWrongInputAndClear() {
//     bool hasWrong = false;
//     for (int i = 0; i < widget.mathData.matrixVolume[0]; i++) {
//       for (int j = 0; j < widget.mathData.matrixVolume[1]; j++) {
//         if (recognitionCarryResults[i][j] == "?"){
//           hasWrong = true;
//           recognitionCarryZoneKeys[i][j].currentState?.clear();
//         }
//       }
//     }
//
//
//     for (int i = 0; i < widget.mathData.matrixVolume[2]; i++) {
//       for (int j = 0; j < widget.mathData.matrixVolume[3]; j++) {
//         if (recognitionProgressResults[i][j] == "?"){
//           hasWrong = true;
//           recognitionProgressZoneKeys[i][j].currentState?.clear();
//         }
//       }
//     }
//
//
//     for (int i = 0; i < widget.mathData.matrixVolume[4]; i++) {
//       for (int j = 0; j < widget.mathData.matrixVolume[5]; j++) {
//         if (recognitionAnswerResults[i][j] == "?"){
//           hasWrong = true;
//
//           recognitionAnswerZoneKeys[i][j].currentState?.clear();
//         }
//       }
//     }
//
//     return hasWrong;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     _initRecognitionKeys(widget.mathData.matrixVolume);
//
//     recognitionTotalResults = [
//       recognitionCarryResults,
//       recognitionProgressResults,
//       recognitionAnswerResults,
//     ];
//   }
//
//   void _updateResults(List<List<List<String>>> newResults) {
//     setState(() {
//       recognitionCarryResults = newResults[0];
//       recognitionProgressResults = newResults[1];
//       recognitionAnswerResults = newResults[2];
//       recognitionTotalResults = [newResults[0], newResults[1], newResults[2]];
//     });
//     widget.onResultsUpdated(newResults); // 상위로 전달
//   }
//   BuildContext? _dialogContext;
//
//   void _showLoadingDialogLegacy() {
//     showDialog(
//       context: context,         // 여기서 context는 화면(라우트) context
//       barrierDismissible: false,
//       builder: (dialogCtx) {
//         // 다이얼로그 전용 context 저장
//         _dialogContext = dialogCtx;
//         return Dialog(
//           child: Row(
//             children: const [
//               CircularProgressIndicator(),
//               SizedBox(width: 8),
//               Text("로딩 중..."),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _showLoadingDialog() {
//     showDialog(
//       context: context,
//       // 기본값은 null이며, MaterialApp theme에 따라 대략 0.32~0.5 정도로 어둡게 설정될 수 있음
//       // 아래처럼 직접 지정하면, 예: 반투명 검정색 (0.2 정도)
//       barrierColor: Colors.black.withOpacity(0.2),
//
//       // 사용자가 밖(배경)을 클릭해도 다이얼로그가 닫히지 않게 하려면 false
//       barrierDismissible: false,
//       builder: (dialogCtx) {
//         _dialogContext = dialogCtx;
//         return Dialog(
//           child: Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: const [
//                 CircularProgressIndicator(),
//                 SizedBox(width: 8),
//                 Text("로딩 중..."),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _hideLoadingBanner() {
//     ScaffoldMessenger.of(context).clearMaterialBanners();
//   }
//
//   Future<void> _runRecognition() async {
//       final allKeys = [
//         ...recognitionCarryZoneKeys.expand((row) => row),
//         ...recognitionProgressZoneKeys.expand((row) => row),
//         ...recognitionAnswerZoneKeys.expand((row) => row),
//       ];
//
//       // ✅ 모든 recognize() 호출을 동시에 실행하고 기다림
//       await Future.wait(
//         allKeys.map((key) => key.currentState?.recognize() ?? Future.value()),
//       );
//
//       // ✅ recognize가 모두 끝난 후 setResults
//       setState(() {
//         setResults("carry");
//         setResults("progress");
//         setResults("answer");
//       });
//
//       _updateResults([
//         recognitionCarryResults,
//         recognitionProgressResults,
//         recognitionAnswerResults,
//       ]);
//
//     _showLoadingDialog();
//
//     // 2) 인식 작업
//     await Future.delayed(const Duration(seconds: 1)); // 가짜 작업
//
//     // 3) 인식 결과 확인
//     final bool hasUnrecognized = findWrongInputAndClear();
//     // 4) 다이얼로그 닫기
//     if (_dialogContext != null) {
//       Navigator.of(_dialogContext!).pop(); // 다이얼로그만 pop
//       _dialogContext = null;
//     }
//
//     // 5) 팝업(결과창) 표시 or 에러 안내
//     if (hasUnrecognized) {
//       // 인식 실패 안내
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("인식 안 된 칸이 있습니다.")),
//       );
//     } else {
//       _showResultPopup(context, recognitionTotalResults, []);
//     }
//   }
//
//   void _toggleAnswer() {
//     setState(() {
//       _isAnswerVisible = !_isAnswerVisible; // ✅ 버튼을 누를 때마다 정답 표시 여부 변경
//     });
//   }
//
//   Widget getCheckAnswerButton() {
//     return ElevatedButton(
//       onPressed: _toggleAnswer,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       child: Text(_isAnswerVisible ? "정답 숨기기" : "정답 확인"),
//     );
//   }
//
//   Widget returnProblemPage() {
//     // ✅ 문제 유형별 위젯 표시
//     if (isOneDigit) {
//       return MProblemSingleline(
//         mathData: widget.mathData,
//         onResultUpdated: _updateResults,
//         initialResult: recognitionTotalResults,
//         recognitionAnswerZoneKeys: recognitionAnswerZoneKeys,
//       );
//     }
//     if (isAddSub) {
//       return MProblemAddSub(
//         mathData: widget.mathData,
//         onResultUpdated: _updateResults,
//         initialResult: recognitionTotalResults,
//         recognitionCarryZoneKeys: recognitionCarryZoneKeys,
//         recognitionProgressZoneKeys: recognitionProgressZoneKeys,
//         recognitionAnswerZoneKeys: recognitionAnswerZoneKeys,
//       );
//     }
//     if (isMultiplication) {
//       return MProblemMult(
//         mathData: widget.mathData,
//         onResultUpdated: _updateResults,
//         initialResult: recognitionTotalResults,
//         recognitionCarryZoneKeys: recognitionCarryZoneKeys,
//         recognitionProgressZoneKeys: recognitionProgressZoneKeys,
//         recognitionAnswerZoneKeys: recognitionAnswerZoneKeys,
//       );
//     }
//     if (isDivision) {
//       return MProblemDiv(
//         mathData: widget.mathData,
//         onResultUpdated: _updateResults,
//         initialResult: recognitionTotalResults,
//         recognitionCarryZoneKeys: recognitionCarryZoneKeys,
//         recognitionProgressZoneKeys: recognitionProgressZoneKeys,
//         recognitionAnswerZoneKeys: recognitionAnswerZoneKeys,
//       );
//     }
//     else {
//       return MProblemDivRemainder(
//         mathData: widget.mathData,
//         onResultUpdated: _updateResults,
//         initialResult: recognitionTotalResults,
//         recognitionCarryZoneKeys: recognitionCarryZoneKeys,
//         recognitionProgressZoneKeys: recognitionProgressZoneKeys,
//         recognitionAnswerZoneKeys: recognitionAnswerZoneKeys,
//       );
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(100, 10, 200, 10),
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white, // 배경색 (필요에 따라 변경 가능)
//         border: Border.all(
//           color: Colors.greenAccent, // 테두리 색상
//           width: 3, // 테두리 두께
//         ),
//         borderRadius: BorderRadius.circular(16), // 둥근 모서리
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
//         children: [
//           const SizedBox(height: 100),
//           returnProblemPage(),
//           const SizedBox(height: 100),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
//
//               // 🔸 크기 키움
//               textStyle: const TextStyle(
//                 fontSize: 16, // 🔸 텍스트 크기 키움
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             onPressed: () async {
//               final currentContext = context; // ✅ async 전에 context 저장
//               //_showLoadingDialog(currentContext); // 안전
//               //_showLoadingDialog(); // 안전
//               await _runRecognition();
//               //
//               // if (mounted)
//               //   Navigator.of(currentContext).pop(); // ✅ mounted 체크 후 pop
//               //
//               // if (mounted) {
//               //   _showResultPopup(currentContext, recognitionTotalResults, []);
//               // }
//             },
//             child: const Text("결과 확인"),
//           ),
//
//           // ✅ 팝업 띄우기
//         ],
//       ),
//     );
//   }
// }
//
// Widget _buildResultText(String label, List<List<String>> data) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         '[$label]',
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//       ),
//       const SizedBox(height: 4),
//       ...data.map((row) => Text(row.toString())).toList(),
//       const SizedBox(height: 12),
//     ],
//   );
// }
//
// void _showResultPopup(
//   BuildContext context,
//   List<List<List<String>>> results,
//   List<List<String>> answer,
// ) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Dialog(
//         child: SingleChildScrollView(
//           child: Container(
//             width: MediaQuery.of(context).size.width * 0.9,
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "결과 확인 (answer, response)",
//                   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 30),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Flexible(child: MPPresentMatrixAnswer(gridData: answer)),
//                     const SizedBox(width: 30),
//                     Flexible(
//                       child: MPPresentMatrixResponse(gridData: results[0]),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 40),
//
//                 const Divider(thickness: 2),
//                 const Text(
//                   "🧪 디버그용 결과 보기",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//
//                 _buildResultText("Carry Results", results[0]),
//                 _buildResultText("Progress Results", results[1]),
//                 _buildResultText("Answer Results", results[2]),
//
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text("닫기"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
//
// void _showLoadingDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false, // ❌ 밖 클릭해도 안 닫힘
//     builder: (context) {
//       return Dialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               CircularProgressIndicator(),
//               SizedBox(width: 16),
//               Text("인식 중입니다...", style: TextStyle(fontSize: 16)),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
