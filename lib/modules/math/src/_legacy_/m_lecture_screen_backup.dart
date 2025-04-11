// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_modular/flutter_modular.dart';
// import '../../../../shared/widgets/appbar_widget.dart';
// import '../../../../shared/widgets/new_header_widget.dart';
// import '../../../../shared/widgets/new_question_text.dart';
// import '../services/basa_math_decoder.dart';
// import '../services/basa_math_encoder.dart';
// import '../services/feedback_animator_service.dart';
// import '../services/m_problem_manager.dart';
// import '../services/m_problem_state_manager.dart';
// import '../utils/math_ui_constant.dart';
// import '../widgets/m_animator/m_feedback_lottie_widget.dart';
// import '../widgets/m_index_presenter.dart';
// import '../widgets/m_index_presenter_new.dart';
// import 'm_problem_display.dart';
// import 'm_problem_switch_button.dart';
// import 'm_lecture_description_screen.dart';
// import 'm_lecture_stats_screen.dart';
// import 'm_lecture_tutorial_dialog.dart';
//
// enum EvaluationStatus {
//   unSolved,
//   correct,
//   wrong,
//   checked, // 틀렸다가 고쳐 맞춘 경우
// }
//
// class MLectureScreen extends StatefulWidget {
//   final int categoryIndex;
//   final String categoryName;
//   final String categoryDescription;
//   final String imageURL;
//   final bool isTeachingMode;
//   final int problemCount;
//
//   const MLectureScreen({
//     super.key,
//     required this.categoryIndex,
//     required this.categoryName,
//     required this.categoryDescription,
//     required this.imageURL,
//     required this.isTeachingMode,
//     this.problemCount = 5,
//   });
//
//   @override
//   State<MLectureScreen> createState() => _MLectureScreenState();
// }
//
// class _MLectureScreenState extends State<MLectureScreen>
//     with TickerProviderStateMixin {
//   late final MProblemManager _PM;
//   late final MProblemStateManager _PSM;
//   List<EvaluationStatus> evaluationResults = [];
//
//   //0:아직 안품,
//
//   //자료 구조
//   double iconSize = MathUIConstant.iconSize;
//
//   int get categoryRaw => widget.categoryIndex;
//   late int parentCategory = categoryRaw ~/ 100;
//   late int childCategory = categoryRaw % 10;
//
//   //인덱스
//   int idx = 0;
//   bool _minLoadingTimePassed = false;
//
//   //비동기 데이터
//   final BasaMathDecoder _bmDecode = BasaMathDecoder();
//   final BasaMathEncoder _bmEncode = BasaMathEncoder();
//   final _descriptionOverlay = MLectureDescriptionOverlay();
//
//   void _showDescriptionOverlay() {
//     _descriptionOverlay.show(context);
//   }
//
//   bool _isLoading = true;
//   bool _autoMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _PM = MProblemManager(_bmDecode, _bmEncode);
//     _PSM = MProblemStateManager();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _prepareFirstProblem(); // async 초기화 따로 호출
//     });
//   }
//
//   Future<void> _prepareFirstProblem() async {
//     setState(() {
//       _isLoading = true;
//       _minLoadingTimePassed = false;
//     });
//
//     Future.delayed(const Duration(milliseconds: 2000), () {
//       setState(() {
//         _minLoadingTimePassed = true;
//       });
//     });
//     print("✅ API GET INITIATED");
//     await prepareNextProblem(); // 꼭 await 해야 합니다!
//     print("✅ API GET FINISHED");
//     setState(() {
//       _isLoading = false; // 이제 진짜 준비 끝났을 때만 false
//     });
//   }
//
//   bool _isPreparingNextProblem = false;
//
//   Future<void> prepareNextProblem() async {
//     if (_isPreparingNextProblem) return; // 중복 호출 방지
//     _isPreparingNextProblem = true;
//     try {
//       await _PM.load(parentCategory, childCategory, idx, widget.categoryIndex);
//       _PSM.addState();
//       evaluationResults.add(EvaluationStatus.unSolved);
//       setState(() {}); // 새 문제 반영
//     } catch (e) {
//       print("❗ 문제 로딩 중 에러 발생: $e");
//       // 여기에 SnackBar 또는 AlertDialog 넣을 수도 있음
//     } finally {
//       print("EVALUATION RESULTS: $evaluationResults");
//       _isPreparingNextProblem = false;
//     }
//   }
//
//   void _activateAutoMode() {
//     setState(() {
//       _autoMode = !_autoMode;
//     });
//   }
//
//   Future<void> _incrementCounter() async {
//     if (idx >= _PM.history.length - 1) return;
//     setState(() {
//       idx++;
//     });
//   }
//
//   Future<void> _getNextProblem() async {
//     final nextIndex = idx + 1;
//     if (nextIndex % widget.problemCount == 0 && nextIndex != 0) {
//       final shouldContinue = await _showContinueDialog();
//       if (!shouldContinue) {
//         Navigator.of(context).pop(); // 화면 나가기
//         return;
//       }
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     if (_PM.history.length <= nextIndex) {
//       await prepareNextProblem();
//     }
//     setState(() {
//       idx = nextIndex;
//
//       _isLoading = false;
//     });
//   }
//
//   void _decrementCounter() {
//     if (idx <= 0) return;
//     setState(() {
//       idx--;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;
//     double unitSize = MathUIConstant.hSize;
//     return Scaffold(
//       appBar: AppbarWidget(
//         title: null,
//         leading: IconButton(
//           icon: const Icon(Icons.chevron_left, size: 40.0),
//           onPressed: () => Modular.to.pop(),
//         ),
//       ),
//
//       body: Container(
//         //Screenshot으로 감쌀 수 있음.
//         margin: EdgeInsets.fromLTRB(
//           unitSize * 0.7,
//           unitSize * 0.2,
//           unitSize * 0.7,
//           unitSize * 0.1,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.white, // 배경색 (필요에 따라 변경 가능)
//           border: Border.all(
//             color: MathUIConstant.boundaryPurple,
//             width: 3, // 테두리 두께
//           ),
//           borderRadius: BorderRadius.circular(16), // 둥근 모서리
//         ),
//         child: Stack(
//           children: [
//             Center(
//               child:
//                   _isLoading ||
//                           !_minLoadingTimePassed ||
//                           _PM.history.length <= idx
//                       ? const CircularProgressIndicator()
//                       : Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 8,
//                               horizontal: 16,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.purple[100],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   children: [
//                                     IndexPresenterNew(
//                                       indexLabel:
//                                           widget.isTeachingMode
//                                               ? idx + 1
//                                               : _PM
//                                                   .get(idx)
//                                                   .problemMetaData
//                                                   .index,
//                                     ),
//                                     SizedBox(width: unitSize * 0.2),
//                                     Text(
//                                       widget.categoryName,
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.fast_forward),
//                                       onPressed: _activateAutoMode,
//                                       iconSize: MathUIConstant.helperIconSize,
//                                       color:
//                                           _autoMode
//                                               ? Colors.green
//                                               : Color(0xFF999797),
//                                     ),
//                                     SizedBox(width: unitSize * 0.2),
//                                     IconButton(
//                                       onPressed:
//                                           () => showTutorialDialog(context),
//                                       icon: Icon(
//                                         Icons.lightbulb,
//                                         size: MathUIConstant.helperIconSize,
//                                         color: Colors.yellow,
//                                         shadows: [
//                                           BoxShadow(
//                                             color: Colors.black.withAlpha(77),
//                                             blurRadius: 3,
//                                             offset: const Offset(1, 2),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 50),
//
//                           NewHeaderWidget(
//                             headerText: widget.categoryName,
//                             headerTextSize: width * 0.028,
//                             subTextSize: height * 0.018,
//                             subText:
//                                 widget.isTeachingMode ? "선생님과 풀기" : "스스로 하기",
//                           ),
//                           NewQuestionTextWidget(
//                             questionText: widget.categoryDescription,
//                             questionTextSize: width * 0.02,
//                           ),
//                           SizedBox(height: height * 0.02),
//
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               IndexPresenter(
//                                 indexLabel:
//                                     widget.isTeachingMode
//                                         ? idx + 1
//                                         : _PM.get(idx).problemMetaData.index,
//                               ),
//                               IconButton(
//                                 icon: Icon(
//                                   Icons.refresh,
//                                   size: MathUIConstant.refreshIconSize,
//                                   color: Color(0xFF999797),
//                                 ),
//                                 onPressed: () {
//                                   final currentState =
//                                       _PM
//                                           .get(idx)
//                                           .problemDisplayKey
//                                           .currentState;
//                                   if (currentState != null) {
//                                     currentState.clearResponseBlocks();
//                                   }
//                                 },
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.fast_forward),
//                                 onPressed: _activateAutoMode,
//                                 iconSize: MathUIConstant.helperIconSize,
//                                 color:
//                                     _autoMode
//                                         ? Colors.green
//                                         : Color(0xFF999797),
//                               ),
//                               IconButton(
//                                 onPressed: () => showTutorialDialog(context),
//                                 icon: Icon(
//                                   Icons.lightbulb,
//                                   size: width * 0.04,
//                                   color: Colors.yellow,
//                                   shadows: [
//                                     BoxShadow(
//                                       color: Colors.black.withAlpha(77),
//                                       blurRadius: 3,
//                                       offset: const Offset(1, 2),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Spacer(flex: 4),
//                           Column(
//                             children: [
//                               MProblemDisplay(
//                                 key: _PM.get(idx).problemDisplayKey,
//                                 problemMetaData: _PM.get(idx).problemMetaData,
//                                 isLectureMode: false,
//                                 correctResponse3DList:
//                                     _PM.get(idx).correctResponse3DList,
//                                 userResponse: _PM.get(idx).userResponse,
//                                 onCheckCorrect: (bool isCorrect) {
//                                   if (!_PM
//                                       .get(idx)
//                                       .userResponse
//                                       .hasAnyInput()) {
//                                     print("예외상황: 작성답안 없음");
//                                     return;
//                                   }
//                                   if (isCorrect) {
//                                     if (evaluationResults[idx] ==
//                                         EvaluationStatus.unSolved) {
//                                       print("ISCORRECT - UNSOLVED");
//                                       evaluationResults[idx] =
//                                           EvaluationStatus.correct;
//                                     } else {
//                                       print("ISCORRECT - WASSOLVED");
//                                       evaluationResults[idx] =
//                                           EvaluationStatus.checked;
//                                     }
//                                   } else {
//                                     print("ISNOTCORRECT");
//                                     evaluationResults[idx] =
//                                         EvaluationStatus.wrong;
//                                   }
//                                   print("");
//                                   print(
//                                     "CURRENT EVALUATION STATUS: ${evaluationResults[idx]}",
//                                   );
//                                   print("");
//
//                                   // 🎯 여기에서 애니메이션 트리거!
//                                   final asset = getAnimationAsset(
//                                     evaluationResults[idx],
//                                   );
//                                   if (asset.isNotEmpty) {
//                                     FeedbackAnimatorService().setAnimatorStatus(
//                                       asset,
//                                     );
//                                   }
//
//                                   if (widget.isTeachingMode) {
//                                     print("teaching session");
//                                   } else {
//                                     print("child is sending data");
//                                     _PM
//                                         .get(idx)
//                                         .sendResultOnceIfNeeded(_bmEncode);
//                                   }
//                                 },
//                                 stateModel: _PSM.get(idx),
//                               ),
//                             ],
//                           ),
//                           Spacer(flex: 6),
//                           Container(
//                             margin: EdgeInsets.only(
//                               bottom: MathUIConstant.hSize * 0.2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.white, // 배경색 (필요에 따라 변경 가능)
//                               border: Border.all(
//                                 color: MathUIConstant.boundaryPurple,
//                                 width: 3, // 테두리 두께
//                               ),
//                               borderRadius: BorderRadius.circular(16), // 둥근 모서리
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Row(
//                                   children: [
//                                     BasaMSwitchButton(
//                                       psm: _PSM.get(idx),
//                                       onNextProblem: () {
//                                         print("INCREMENT COUNTER");
//                                         _getNextProblem();
//                                       },
//                                       autoMode: _autoMode,
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.arrow_back),
//                                       onPressed: _decrementCounter,
//                                       iconSize: MathUIConstant.helperIconSize,
//                                       color: const Color(0xFF999797),
//                                     ),
//                                     SizedBox(width: MathUIConstant.wSize * 0.3),
//                                     IconButton(
//                                       icon: const Icon(Icons.arrow_forward),
//                                       onPressed: _incrementCounter,
//                                       iconSize: MathUIConstant.helperIconSize,
//                                       color: const Color(0xFF999797),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//             ),
//             // 🎉 정답 애니메이션
//             if (evaluationResults.isNotEmpty && idx < evaluationResults.length)
//               ValueListenableBuilder<String?>(
//                 valueListenable: FeedbackAnimatorService().currentAsset,
//                 builder: (context, asset, child) {
//                   if (asset == null)
//                     return const SizedBox.shrink(); // 애니메이션 안띄움
//                   return FeedbackLottieWidget(asset: asset); // 애니메이션 실행
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<bool> _showContinueDialog() async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder:
//               (context) => AlertDialog(
//                 title: const Text("문제 풀이 종료"),
//                 content: const Text("문제를 충분히 푸셨어요! 돌아가시겠어요?"),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(true),
//                     child: const Text("계속 풀기"),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(false),
//                     child: const Text("돌아가기"),
//                   ),
//                 ],
//               ),
//         ) ??
//         false; // dialog가 dismiss된 경우 기본 false
//   }
// }
