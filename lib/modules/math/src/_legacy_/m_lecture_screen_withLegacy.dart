// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import '../../../../shared/widgets/header_widget.dart';
// import '../services/basa_math_decoder.dart';
// import '../models/m_problem_metadata.dart';
// import '../services/m_response.dart';
// import '../utils/math_basic.dart';
// import '../utils/math_hardcoder.dart';
// import '../utils/math_ui_constant.dart';
// import '../utils/num_pair.dart';
// import '../widgets/m_index_presenter.dart';
// import '../widgets/m_problem_display.dart';
// import '../widgets/m_problem_switch_button.dart'; // NumPair와 CategoryMapper 정의되어 있는 파일
//
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
//   final BasaMathDecoder _form = BasaMathDecoder();
//   final List<GlobalKey<MProblemDisplayState>> _problemKeys = [];
//   final List<MProblemMetadata> _mathDataList = [];
//   final List<MResponse> _userResponses = [];
//   final List<List<List<List<String>>>> _answer = [];
//
//   int get categoryRaw => widget.categoryIndex;
//   late int parentCategory = categoryRaw ~/ 100;
//   late int childCategory = categoryRaw % 10;
//
//   List<int> matrixSize = [0, 0, 0, 0, 0, 0];
//   String op = "";
//   int num1 = 0;
//   int num2 = 0;
//   int indexCounter = 0;
//   double iconSize = MathUIConstant.iconSize;
//
//   late Future<Map<String, dynamic>> _futureJson;
//   late MProblemMetadata md;
//
//   bool? _isCorrect; // ✅ 정답 여부 상태
//   bool _isLoading = true;
//   bool _autoMode = false;
//   bool isGameMode = false; // 나중에 외부에서 true/false 조절 가능
//   bool isAPImode = true;
//   static const double timeLimit = 20.0; // 제한 시간 (초)
//   late AnimationController _lottieController;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   late Timer _gameTimer;
//   double _remainingTime = timeLimit;
//
//
//   @override
//   void initState() {
//     super.initState();
//     op = getOperator(widget.categoryIndex);
//     _problemKeys.add(GlobalKey<MProblemDisplayState>());
//     _lottieController = AnimationController(vsync: this);
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     );
//     _fadeAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(_fadeController);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeScreen(); // async 초기화 따로 호출
//     });
//
//     if (isGameMode) _startGameTimer();
//   }
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   op = getOperator(widget.categoryIndex);
//   //
//   //   if (isAPImode){
//   //     print("✅API GET INITIATED");
//   //     getMathDataAndAnswer();
//   //     print("✅API GET FINISHED");
//   //   } else{
//   //     getMathData();
//   //     _userResponses.add(MResponse.init([], md.matrixVolume));
//   //     _answer.add(generateDummyAnswer(indexCounter + 1, md.matrixVolume));
//   //   }
//   //
//   //
//   //   _problemKeys.add(GlobalKey<MProblemState>());
//   //
//   //   _lottieController = AnimationController(vsync: this);
//   //   _fadeController = AnimationController(
//   //     vsync: this,
//   //     duration: const Duration(seconds: 1), // 3초간 사라지게
//   //   );
//   //   _fadeAnimation = Tween<double>(
//   //     begin: 1.0,
//   //     end: 0.0,
//   //   ).animate(_fadeController);
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     setState(() {}); // currentState가 null이 아니게 되는 시점에 강제 리빌드
//   //   });
//   //   if (isGameMode) _startGameTimer();
//   //   _isLoading = false;
//   // }
//
//   Future<void> _initializeScreen() async {
//     if (isAPImode) {
//       print("✅ API GET INITIATED");
//       await getMathDataAndAnswer(); // 꼭 await 해야 합니다!
//       print("✅ API GET FINISHED");
//     } else {
//       getMathData();
//       _userResponses.add(MResponse.init([], md.matrixVolume));
//       _answer.add(generateDummyAnswer(indexCounter + 1, md.matrixVolume));
//     }
//
//     setState(() {
//       _isLoading = false; // 이제 진짜 준비 끝났을 때만 false
//     });
//   }
//
//   @override
//   void dispose() {
//     _lottieController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }
//
//   Future<void> getMathDataAndAnswer() async{
//     if (_mathDataList.length > indexCounter) {
//       md = _mathDataList[indexCounter]; // 이미 생성된 문제 재사용
//     } else {
//       _futureJson = _form.fetchAPIData(parentCategory,childCategory);
//       md = _form.getMathDataFromResponse(await _futureJson, indexCounter);
//       _mathDataList.add(md); // 새로 생성된 문제는 저장
//     }
//     num1 = md.num1;
//     num2 = md.num2;
//     matrixSize = md.matrixVolume;
//     _answer.add(_form.getAnswerFromResponse(await _futureJson, indexCounter, widget.categoryIndex));
//     _userResponses.add(MResponse.init([], md.matrixVolume));
//   }
//   void getMathData() {
//       if (_mathDataList.length > indexCounter) {
//         md = _mathDataList[indexCounter]; // 이미 생성된 문제 재사용
//       } else {
//         md = getRandomMathData(widget.categoryIndex, indexCounter);
//         _mathDataList.add(md); // 새로 생성된 문제는 저장
//       }
//     num1 = md.num1;
//     num2 = md.num2;
//     matrixSize = md.matrixVolume;
//   }
//
//   void _updateResults(List<List<List<String>>> result) {}
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
//
//
//   void _activateAutoMode() {
//     setState(() {
//       _autoMode = true;
//     });
//
//     // 이미 정답인 상태면 즉시 넘어가기
//     final currentState = _problemKeys[indexCounter].currentState;
//     if (currentState?.isAnswerCorrect() == true) {
//       _incrementCounter();
//     }
//   }
//   Future<void> _incrementCounter() async {
//     final nextIndex = indexCounter + 1;
//
//     // 데이터를 먼저 추가
//     if (_userResponses.length <= nextIndex) {
//       await getMathDataAndAnswer();
//       _problemKeys.add(GlobalKey<MProblemDisplayState>());
//     }
//
//     // indexCounter 증가는 데이터 준비가 끝난 뒤
//     setState(() {
//       indexCounter = nextIndex;
//     });
//   }
//   // void _incrementCounter() {
//   //   setState(() {
//   //     indexCounter++;
//   //     getMathData();
//   //
//   //     if (_userResponses.length <= indexCounter) {
//   //       _userResponses.add(MResponse.init([], md.matrixVolume));
//   //     }
//   //     if (_answer.length <= indexCounter) {
//   //       _answer.add(generateDummyAnswer(indexCounter + 1, md.matrixVolume));
//   //     }
//   //     if (_problemKeys.length <= indexCounter) {
//   //       _problemKeys.add(GlobalKey<MProblemState>());
//   //     }
//   //   });
//   // }
//
//   void _decrementCounter() {
//     if (indexCounter <= 0) return;
//     setState(() {
//       indexCounter--;
//       getMathData(); // 이제 이건 기존 문제를 불러옴!
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
//                   _isLoading || _answer.length <= indexCounter || _userResponses.length <= indexCounter
//                       ? const CircularProgressIndicator()
//                       : Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//
//                             // 🔹 버튼들도 중앙 정렬
//                             children: [
//                               IndexPresenter(indexLabel: indexCounter),
//                               IconButton(
//                                 icon: Icon(
//                                   Icons.refresh,
//                                   size: iconSize,
//                                   color: Color(0xFF999797),
//                                 ),
//                                 onPressed: () {
//                                   final currentState =
//                                       _problemKeys[indexCounter].currentState;
//                                   if (currentState != null) {
//                                     currentState.clearResponseBlocks();
//                                   }
//                                 },
//                               ),
//                             ],
//                           ),
//                           Spacer(flex: 4),
//                           if (indexCounter >= 0)
//                             Column(
//                               children: [
//                                 MProblemDisplay(
//                                   key: _problemKeys[indexCounter],
//                                   problemMetaData: md,
//                                   isTest: false,
//                                   //onResultsUpdated: _updateResults,
//                                   correctResponse3DList: _answer[indexCounter],
//
//                                   userResponse: _userResponses[indexCounter],
//                                   onCheckCorrect: (bool isCorrect) {
//                                     setState(() {
//                                       _isCorrect = isCorrect;
//                                       if (_autoMode && isCorrect) {
//                                         Future.delayed(
//                                           Duration(milliseconds: 300),
//                                           () {
//                                             _incrementCounter();
//                                           },
//                                         );
//                                       }
//                                     });
//                                   },
//                                 ),
//                                 SizedBox(height: 100),
//                                 SwitchButtonState(
//                                   onRunRecognition: () async {
//                                     await _problemKeys[indexCounter]
//                                         .currentState
//                                         ?.runRecognitionWithDisplay();
//
//                                     // 애니메이션 재생
//                                     _lottieController.reset();
//                                     _fadeController.reset();
//                                     _lottieController.forward();
//
//                                     // 천천히 사라지기 시작
//                                     _fadeController.forward();
//                                   },
//                                   onNextProblem: _incrementCounter,
//                                   onToggleDisplayState: () {
//                                     _problemKeys[indexCounter].currentState
//                                         ?.toggleShowingUserInputState();
//                                     setState(() {}); // 꼭 필요!!
//                                   },
//                                   onToggleInputState: () {
//                                     _problemKeys[indexCounter].currentState
//                                         ?.toggleHasAnswerState();
//                                     setState(() {}); // 꼭 필요!!
//                                   },
//                                 ),
//                               ],
//                             ),
//                           Spacer(flex: 6),
//                           Container(
//                             margin: const EdgeInsets.only(bottom: 50), // 하단 마진
//                             child:
//                             Container(
//                               margin: const EdgeInsets.only(bottom: 50),
//                               child: isGameMode
//                                   ? Column(
//                                 children: [
//                                   Text(
//                                     "남은 시간: ${_remainingTime.toInt()}초",
//                                     style: const TextStyle(
//                                       fontSize: 28,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   LinearProgressIndicator(
//                                     value: _remainingTime / timeLimit,
//                                     backgroundColor: Colors.grey[300],
//                                     color: Colors.redAccent,
//                                     minHeight: 10,
//                                   ),
//                                 ],
//                               )
//                                   : Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const SizedBox(width: 50),
//                                       IconButton(
//                                         icon: const Icon(Icons.fast_forward),
//                                         onPressed: _activateAutoMode,
//                                         iconSize: 50,
//                                         color: const Color(0xFF999797),
//                                       ),
//                                     ],
//                                   ),
//                                   Row(
//                                     children: [
//                                       IconButton(
//                                         icon: const Icon(Icons.arrow_back),
//                                         onPressed: _decrementCounter,
//                                         iconSize: 50,
//                                         color: const Color(0xFF999797),
//                                       ),
//                                       const SizedBox(width: 50),
//                                       IconButton(
//                                         icon: const Icon(Icons.arrow_forward),
//                                         onPressed: _incrementCounter,
//                                         iconSize: 50,
//                                         color: const Color(0xFF999797),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//             ),
//             // 🎉 정답 애니메이션
//             Positioned.fill(
//               child: IgnorePointer(
//                 child: FadeTransition(
//                   opacity:
//                       _isCorrect == true
//                           ? _fadeAnimation
//                           : AlwaysStoppedAnimation(0.0),
//                   child: Transform(
//                     alignment: Alignment.centerLeft,
//                     transform: Matrix4.identity()..scale(1.0, -1.5),
//                     child: Lottie.asset(
//                       "assets/lottie/correct.json",
//                       controller: _lottieController,
//                       onLoaded: (composition) {
//                         _lottieController.duration = composition.duration * 0.4;
//                       },
//                       repeat: false,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // ❌ 오답 애니메이션
//             Positioned.fill(
//               child: IgnorePointer(
//                 child: FadeTransition(
//                   opacity:
//                       _isCorrect == false
//                           ? _fadeAnimation
//                           : AlwaysStoppedAnimation(0.0),
//                   child: Transform(
//                     alignment: Alignment.center,
//                     transform: Matrix4.identity()..scale(1.0, 1.0),
//                     child: Lottie.asset(
//                       "assets/lottie/cross_mark_animation.json",
//                       controller: _lottieController,
//                       onLoaded: (composition) {
//                         _lottieController.duration = composition.duration * 0.4;
//                       },
//                       repeat: false,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
