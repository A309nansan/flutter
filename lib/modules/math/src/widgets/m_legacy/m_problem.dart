// import 'package:flutter/material.dart';
// import '../../../../../../shared/digit_recognition/widgets/recognition_button.dart';
// import '../../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
// import '../../../models/math_paper_model.dart';
// import '../../../utils/math_basic.dart';
// import '../../m_index_presenter.dart';
// import 'announcement.dart';
// import 'm_mult_problem.dart';
// import '../mp_input_list.dart';
// import 'mp_present_matrix.dart';
// import '../m_singleline_problem.dart';
// import 'm_addsub_problem.dart';
// import '../mp_present_matrix_answer.dart';
// import '../mp_present_matrix_response.dart';
//
// class MProblem extends StatefulWidget {
//   final MathProblem problemData;
//   final bool isTest;
//   final List<List<String>> initialResults;
//   final Function(List<List<String>>) onResultsUpdated;
//
//   const MProblem({
//     Key? key,
//     required this.problemData,
//     required this.isTest,
//     required this.initialResults,
//     required this.onResultsUpdated, }) : super(key: key);
//
//   @override
//   _MProblemState createState() => _MProblemState();
// }
//
// class _MProblemState extends State<MProblem> {
//   bool _isAnswerVisible = false; // ✅ 정답 표시 여부 상태 관리
//
//   int get number1 => int.parse(widget.problemData.num1);
//   int get number2 => int.parse(widget.problemData.num2);
//   bool get isOneDigit => number1 < 10 && number2 < 10 && number1 != 0;
//   bool get isAnnouncement => widget.problemData.msg.isNotEmpty;
//   bool get isAddSub => (widget.problemData.operand == "add" || widget.problemData.operand == "sub") && !isOneDigit;
//   bool get isMultDiv => (widget.problemData.operand == "mult" || widget.problemData.operand == "div") && !isOneDigit;
//   bool get isDivision => widget.problemData.operand == "div" && !isOneDigit;
//   List<List<String>> results = [];
//   @override
//   void initState() {
//     super.initState();
//     results = widget.initialResults; // 초기 결과 복사
//   }
//
//   void _updateResults(List<List<String>> newResults) {
//     setState(() {
//       results = newResults;
//     });
//     widget.onResultsUpdated(newResults); // 상위로 전달
//   }
//
//   void _toggleAnswer() {
//     setState(() {
//       _isAnswerVisible = !_isAnswerVisible; // ✅ 버튼을 누를 때마다 정답 표시 여부 변경
//     });
//   }
//
//   Widget getCheckAnswerButton(){
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
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(40.0),
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
//         children: [
//           const SizedBox(height: 100),
//
//           // ✅ 문제 유형별 위젯 표시
//           if (isAnnouncement) MAnnouncement(problemData: widget.problemData),
//           if (isOneDigit) MSinglelineProblem(
//               problemData: widget.problemData,
//               onResultUpdated: _updateResults,
//               initialResult: results,
//           ),
//           if (isAddSub) MAddSubProblem(
//               problemData: widget.problemData,
//               onResultUpdated: _updateResults,
//               initialResult: results,
//           ),
//           if (isMultDiv) MMultProblem(
//               problemData: widget.problemData,
//               onResultUpdated: _updateResults,
//               initialResult: results,
//           ),
//
//           if (!isAnnouncement) const SizedBox(height: 100),
//           if (!isAnnouncement) ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18), // 🔸 크기 키움
//
//               textStyle: const TextStyle(
//                 fontSize: 16, // 🔸 텍스트 크기 키움
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             onPressed: () => _showResultPopup(context, results, toString2DArr(widget.problemData.ansDetail)), // ✅ 팝업 띄우기
//             child: const Text("결과 확인"),
//           ),
//           const SizedBox(height: 50),
//
//           //if(!isAnnouncement) getCheckAnswerButton(),
//           // ✅ 정답 확인 버튼 추가
//           // ElevatedButton(
//           //   onPressed: _toggleAnswer,
//           //   style: ElevatedButton.styleFrom(
//           //     backgroundColor: Colors.blue,
//           //     foregroundColor: Colors.white,
//           //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           //   ),
//           //   child: Text(_isAnswerVisible ? "정답 숨기기" : "정답 확인"),
//           // ),
//
//           // ✅ 정답 표시 (버튼 클릭 시 보이게)
//         ],
//       ),
//     );
//   }
// }
//
// void _showResultPopup(BuildContext context, List<List<String>> results, List<List<String>> answer) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Dialog(
//         child: SingleChildScrollView( // ✅ 스크롤 가능하도록 변경
//           child: Container(
//             width: MediaQuery.of(context).size.width * 0.9, // ✅ 다이얼로그 크기 조정
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   "결과 확인 (answer, response)",
//                   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 200),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center, // ✅ 중앙 정렬
//                   children: [
//                     Flexible(
//                       child: MPPresentMatrixAnswer(gridData: answer),
//                     ),
//                     const SizedBox(width: 30), // ✅ 간격 축소
//                     Flexible(
//                       child: MPPresentMatrixResponse(gridData: results),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 40),
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
