// import 'package:flutter/material.dart';
// import 'package:nansan_flutter/modules/math/src/widgets/return_answer_page.dart';
// import 'package:nansan_flutter/modules/math/src/widgets/return_problem_page.dart';
// import '../models/m_problem_metadata.dart';
// import '../models/m_problem_state_model.dart';
// import '../utils/math_basic.dart';
// import '../services/m_response.dart';
// import 'm_present/mp_present_matrix_response.dart';
//
// class MProblemDisplay extends StatefulWidget {
//   final MProblemMetadata problemMetaData;
//   final bool isTest;
//   final Function(bool isCorrect) onCheckCorrect;
//   final List<List<List<String>>> correctResponse3DList;
//   final MResponse userResponse;
//
//   const MProblemDisplay({
//     Key? key,
//     required this.problemMetaData,
//     required this.isTest,
//     required this.onCheckCorrect,
//     required this.correctResponse3DList,
//     required this.userResponse,
//   }) : super(key: key);
//
//   @override
//   MProblemDisplayState createState() => MProblemDisplayState();
// }
//
// class MProblemDisplayState extends State<MProblemDisplay> {
//   int get number1 => widget.problemMetaData.num1;
//
//   int get number2 => widget.problemMetaData.num2;
//
//   bool get isOneDigit => widget.problemMetaData.type == "SingleLine";
//   bool get isAddSub => widget.problemMetaData.type == "AddSub";
//   bool get isMultiplication => widget.problemMetaData.type == "Multiplication";
//   bool get isDivision => widget.problemMetaData.type == "Division";
//   bool get isDivisionRemainder => widget.problemMetaData.type == "DivisionRemainder";
//
//   bool _hasAnswer = false;
//   bool _isAnswerCorrect = false;
//   bool _isShowingUserInput = true;
//   bool _isWritingEnabled = true;
//   List<List<List<String>>> recognitionTotalResults = [];
//   late final MProblemStateModel stateModel;
//   BuildContext? _dialogContext;
//
//   void setShowingUserInputState(bool state) {
//     print("조건 분기: setDisplayState$state");
//     setState(() {
//       _isShowingUserInput = state;
//     });
//   }
//   void toggleShowingUserInputState() {
//     print("조건 분기: toggleDisplayState");
//     setState(() {
//       _isShowingUserInput = !_isShowingUserInput;
//     });
//   }
//
//   void toggleHasAnswerState() {
//     setState(() {
//       _hasAnswer = !_hasAnswer;
//     });
//   }
//   void setHasAnswerState(bool state) {
//     setState(() {
//       _hasAnswer = state;
//     });
//   }
//
//   void toggleWritingEnabledState(){
//     setState(() {
//       _isWritingEnabled = !_isWritingEnabled;
//       widget.userResponse.toggleWritableState(_isWritingEnabled); // 입력 가능 여부 동기화
//     });
//   }
//   void setWritingEnabledState(bool state) {
//     setState(() {
//       _isWritingEnabled = state;
//       widget.userResponse.toggleWritableState(_isWritingEnabled); // 입력 가능 여부 동기화
//     });
//   }
//
//   ///mProblemDisplay._isShowingUserInput 값을 반환.
//   bool isShowingUserInput() {
//     return this._isShowingUserInput;
//   }
//
//   ///mProblemDisplay._isCorrect 값을 반환.
//   bool isAnswerCorrect() {
//     return this._isAnswerCorrect;
//   }
//   ///mProblemDisplay._hasAnswer 값을 반환.
//   bool hasAnswer() {
//     return this._hasAnswer;
//   }
//   ///유저의 답안이 제공된 정답과 일치하는지 확인
//   bool _evaluateUserAnswer() {
//     print("LET ME CHECK");
//     for (int i = 0; i < widget.problemMetaData.matrixVolume[5]; i++) {
//       if (!widget.userResponse.isAnswerValid(
//         recognitionTotalResults[2][0][i],
//         widget.correctResponse3DList[2][0][i],
//       ))
//         return false;
//     }
//     print("LET ME CHECK FINISH");
//     return true;
//   }
//
//
//   void _updateUserResponseResults(List<List<List<String>>> newResults) {
//     setState(() {
//       widget.userResponse.recognitionCarryResults = newResults[0];
//       widget.userResponse.recognitionProgressResults = newResults[1];
//       widget.userResponse.recognitionAnswerResults = newResults[2];
//       recognitionTotalResults = [newResults[0], newResults[1], newResults[2]];
//     });
//   }
//
//
//   Future<void> colorResponseBlocks() async {
//     widget.userResponse.setBgColorByAnswer(widget.correctResponse3DList);
//   }
//
//   Future<void> clearResponseBlocks() async {
//     if (!_isShowingUserInput) {
//       print("IsShowingUserInput = false: clearResponse 거부됨.");
//       return;
//     }
//       widget.userResponse.clearAll();
//       setState(() {
//         _hasAnswer = false;
//       });
//
//   }
//
//   Future<void> runRecognitionWithDisplay() async {
//     print("RECOGNITION START");
//     await widget.userResponse.runRecognition(_updateUserResponseResults);
//     _showLoadingDialog();
//     // 2) 인식 작업
//     await Future.delayed(const Duration(milliseconds: 200)); // 가짜 작업
//     // 3) 인식 결과 확인
//     final bool hasUnrecognized = widget.userResponse.findUnknownInputAndClear();
//     print("FINDWRONGINPUTANDCLEAR FINISHED");
//     if (_dialogContext != null) {
//       Navigator.of(_dialogContext!).pop(); // 다이얼로그만 pop
//       _dialogContext = null;
//     }
//     // 여기서 팝업 대신 상태 변경만
//     // 5) 팝업(결과창) 표시 or 에러 안내
//     if (hasUnrecognized) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("인식 안 된 칸이 있습니다.")));
//     } else {
//       setState(() {
//         _hasAnswer = true; // 화면 전환 조건을 만족시키도록
//         _isAnswerCorrect = _evaluateUserAnswer();
//         widget.onCheckCorrect(_isAnswerCorrect);
//         print("RESULT: $_isAnswerCorrect");
//       });
//     }
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     print("INITSTATE");
//     print("MATRIXVOLUME: " + widget.problemMetaData.matrixVolume.toString());
//     recognitionTotalResults = [
//       widget.userResponse.recognitionCarryResults,
//       widget.userResponse.recognitionProgressResults,
//       widget.userResponse.recognitionAnswerResults,
//     ];
//     Arr3DPrinter(recognitionTotalResults);
//     print("INITSTATE FINISHED");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isTest = false;
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white, // 배경색 (필요에 따라 변경 가능)
//         border: Border.all(
//           color: isTest ? Colors.greenAccent : Colors.transparent, // 테두리 색상
//           width: 3, // 테두리 두께
//         ),
//         borderRadius: BorderRadius.circular(16), // 둥근 모서리
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
//         children: [
//           if (_isShowingUserInput)
//             buildProblemWidget(
//               mathData: widget.problemMetaData,
//               initialResult: recognitionTotalResults,
//               onResultUpdated: _updateUserResponseResults,
//               userResponse: widget.userResponse,
//               onCleared: () {
//                 setState(() {
//                   _hasAnswer = false;
//                 });
//               },
//             ),
//           if (!_isShowingUserInput)
//             buildAnswerWidget(
//               mathData: widget.problemMetaData,
//               userResponse: widget.userResponse,
//               answer: widget.correctResponse3DList,
//               isTest: false,
//               isAnswerDisplay: false,
//               onCleared: () {
//                 setState(() {
//                   _hasAnswer = false;
//                 });
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   void _showLoadingDialog() {
//     showDialog(
//       context: context,
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
// }
//
