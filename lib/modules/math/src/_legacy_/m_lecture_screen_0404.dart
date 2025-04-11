// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../services/basa_math_decoder.dart';
// import '../services/basa_math_encoder.dart';
// import '../services/m_feedback_animator.dart';
// import '../services/m_problem_manager.dart';
// import '../services/m_problem_state_manager.dart';
// import '../utils/math_ui_constant.dart';
// import '../widgets/m_index_presenter.dart';
// import '../widgets/m_problem_display.dart';
// import '../widgets/m_problem_switch_button.dart'; // NumPair와 CategoryMapper 정의되어 있는 파일
// enum EvaluationStatus {
//   unSolved,
//   correct,
//   wrong,
//   checked, // 틀렸다가 고쳐 맞춘 경우
// }
// class MLectureScreen extends StatefulWidget {
//   final int categoryIndex;
//   final String categoryName;
//
//   const MLectureScreen({
//     super.key,
//     required this.categoryIndex,
//     required this.categoryName,
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
//   //0:아직 안품,
//   late FeedbackAnimator _animator;
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
//
//   //조건 분기 관련
//   bool? _isCorrect; // ✅ 정답 여부 상태
//   bool _isLoading = true;
//   bool _autoMode = false;
//   bool isGameMode = false; // 나중에 외부에서 true/false 조절 가능
//
//   //Animation 관련
//   static const double timeLimit = 20.0; // 제한 시간 (초)
//   late AnimationController _lottieController;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   late Timer _gameTimer;
//   double _remainingTime = timeLimit;
//
//   @override
//   void initState() {
//     super.initState();
//     _PM = MProblemManager(_bmDecode, _bmEncode);
//     _PSM = MProblemStateManager();
//     _animator = FeedbackAnimator(vsync: this);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _prepareFirstProblem(); // async 초기화 따로 호출
//     });
//
//     if (isGameMode) _startGameTimer();
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
//   void _infoPopUp() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('ℹ️ 정보'),
//           content: Image.asset(
//             'assets/images/profile_img_3.png',
//             width: 200, // 필요 시 크기 조절
//             height: 200,
//             fit: BoxFit.contain,
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('닫기'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // 팝업 닫기
//               },
//             ),
//           ],
//         );
//       },
//     );
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
//     setState(() {
//       _isLoading = true;
//     });
//     final nextIndex = idx + 1;
//     if (_PM.history.length <= nextIndex) {
//       await prepareNextProblem();
//     }
//     setState(() {
//       idx = nextIndex;
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
//     return Scaffold(
//       appBar: AppBar(title: const Text('선생님과 함께 풀기')),
//       body: Container(
//         margin: const EdgeInsets.fromLTRB(100, 100, 100, 10),
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
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               IndexPresenter(
//                                 indexLabel: _PM.get(idx).problemMetaData.index,
//                               ),
//                               IconButton(
//                                 icon: Icon(
//                                   Icons.refresh,
//                                   size: iconSize,
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
//                             ],
//                           ),
//                           Spacer(flex: 4),
//                           Column(
//                             children: [
//                               MProblemDisplay(
//                                 key: _PM.get(idx).problemDisplayKey,
//                                 problemMetaData: _PM.get(idx).problemMetaData,
//                                 isTest: false,
//                                 correctResponse3DList:
//                                     _PM.get(idx).correctResponse3DList,
//                                 userResponse: _PM.get(idx).userResponse,
//                                 onCheckCorrect: (bool isCorrect) {
//                                   setState(() {
//                                     _isCorrect = isCorrect;
//                                   });
//                                   if (isCorrect) {
//                                     if (evaluationResults[idx] == EvaluationStatus.unSolved){
//                                       evaluationResults[idx] = EvaluationStatus.correct;
//                                     }else {
//                                       evaluationResults[idx] = EvaluationStatus.checked;
//                                     }
//                                   }else{
//                                     evaluationResults[idx] = EvaluationStatus.wrong;
//                                   };
//
//                                   if (!isCorrect)
//                                   _animator.play(); // ✅ 여기서 애니메이션 실행!
//                                   _PM.get(idx).sendResultOnceIfNeeded(_bmEncode);
//                                 },
//                                 stateModel: _PSM.get(idx),
//                               ),
//                               SizedBox(height: 100),
//                               SwitchButtonState(
//                                 psm: _PSM.get(idx),
//                                 onNextProblem: () {
//                                   print("INCREMENT COUNTER");
//                                   _getNextProblem();
//                                 },
//                                 autoMode: _autoMode,
//                               ),
//                             ],
//                           ),
//                           Spacer(flex: 6),
//                           Container(
//                             margin: const EdgeInsets.only(bottom: 50), // 하단 마진
//                             child: Container(
//                               margin: const EdgeInsets.only(bottom: 50),
//                               child:
//                                   isGameMode
//                                       ? Column(
//                                         children: [
//                                           Text(
//                                             "남은 시간: ${_remainingTime.toInt()}초",
//                                             style: const TextStyle(
//                                               fontSize: 28,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.red,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 10),
//                                           LinearProgressIndicator(
//                                             value: _remainingTime / timeLimit,
//                                             backgroundColor: Colors.grey[300],
//                                             color: Colors.redAccent,
//                                             minHeight: 10,
//                                           ),
//                                         ],
//                                       )
//                                       : Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               IconButton(
//                                                 icon: const Icon(
//                                                   Icons.info_outline_rounded,
//                                                 ),
//                                                 onPressed: _infoPopUp,
//
//                                                 iconSize: 50,
//                                                 color: const Color(0xFF999797),
//                                               ),
//                                               const SizedBox(width: 50),
//                                               IconButton(
//                                                 icon: const Icon(
//                                                   Icons.fast_forward,
//                                                 ),
//                                                 onPressed: _activateAutoMode,
//                                                 iconSize: 50,
//                                                 color:
//                                                     _autoMode
//                                                         ? Colors.green
//                                                         : Color(0xFF999797),
//                                               ),
//                                             ],
//                                           ),
//                                           Row(
//                                             children: [
//                                               IconButton(
//                                                 icon: const Icon(
//                                                   Icons.arrow_back,
//                                                 ),
//                                                 onPressed: _decrementCounter,
//                                                 iconSize: 50,
//                                                 color: const Color(0xFF999797),
//                                               ),
//                                               const SizedBox(width: 50),
//                                               IconButton(
//                                                 icon: const Icon(
//                                                   Icons.arrow_forward,
//                                                 ),
//                                                 onPressed: _incrementCounter,
//                                                 iconSize: 50,
//                                                 color: const Color(0xFF999797),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                             ),
//                           ),
//                         ],
//                       ),
//             ),
//             // 🎉 정답 애니메이션
//             _animator.build(isCorrect: evaluationResults[idx]),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animator.dispose();
//     if (isGameMode) {
//       _gameTimer.cancel();
//     }
//     super.dispose();
//   }
//
//   void _startGameTimer() {
//     _remainingTime = timeLimit;
//     _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       setState(() {
//         _remainingTime -= 0.1;
//         if (_remainingTime <= 0) {
//           timer.cancel();
//           _handleTimeUp();
//         }
//       });
//     });
//   }
//
//   void _handleTimeUp() {
//     _gameTimer.cancel();
//
//     showDialog(
//       context: context,
//       barrierDismissible: false, // 바깥 누르면 닫히지 않게
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('시간 초과'),
//           content: const Text('제한 시간이 종료되었습니다.\n처음 화면으로 돌아가시겠습니까?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('취소'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // 팝업만 닫기
//               },
//             ),
//             ElevatedButton(
//               child: const Text('돌아가기'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // 팝업 닫기
//                 Navigator.of(context).pop(); // 이전 화면으로 돌아가기
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
