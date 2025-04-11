// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:nansan_flutter/modules/math/src/utils/math_data_utils.dart';
// import '../services/basa_math_decoder.dart';
// import '../services/basa_math_encoder.dart';
// import '../models/m_problem_metadata.dart';
// import '../services/m_response.dart';
// import '../utils/math_ui_constant.dart';
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
//
//   //자료 구조
//   final List<GlobalKey<MProblemDisplayState>> _problemKeys = [];
//   final List<MProblemMetadata> _mathDataList = [];
//   final List<MResponse> _userResponses = [];
//   final List<List<List<List<String>>>> _answer = [];
//   final List<Map<String, dynamic>> _userRequests = [];
//   final List<bool> _isSent = [];
//   double iconSize = MathUIConstant.iconSize;
//
//   int get categoryRaw => widget.categoryIndex;
//   late int parentCategory = categoryRaw ~/ 100;
//   late int childCategory = categoryRaw % 10;
//
//   //인덱스
//   int indexCounter = 0;
//
//   //비동기 데이터
//   final BasaMathDecoder _bmDecode = BasaMathDecoder();
//   final BasaMathEncoder _bmEncode = BasaMathEncoder();
//   late Future<Map<String, dynamic>> _futureJson;
//   late MProblemMetadata md;
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
//
//   @override
//   void initState() {
//     super.initState();
//         print("MYCATEGORYINDEX: " + widget.categoryIndex.toString());
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
//
//   Future<void> _initializeScreen() async {
//     setState(() {
//       _isLoading = true;
//     });
//       print("✅ API GET INITIATED");
//       await prepareNextProblem(); // 꼭 await 해야 합니다!
//       print("✅ API GET FINISHED");
//     setState(() {
//       _isLoading = false; // 이제 진짜 준비 끝났을 때만 false
//     });
//   }
//   Future<Map<String,dynamic>> fetchRawJsonFromResponse() async{
//     return await _bmDecode.fetchAPIData(parentCategory, childCategory);
//   }
//   MProblemMetadata fetchMathDataFromResponse(Map<String,dynamic> response, int index) {
//     return _bmDecode.getMathDataFromResponse(response, index);
//   }
//   List<List<List<String>>> fetchAnswerFromResponse(Map<String, dynamic> response, int index) {
//     return _bmDecode.getAnswerFromResponse(response, index, widget.categoryIndex);
//   }
//
//   Map<String,dynamic> prepareRawJsonForRequest(Map<String, dynamic> response) {
//     return _bmEncode.initiateRequest(response);
//   }
//
//   void finishRawJsonForRequest(List<Map<String, dynamic>> requestList, int index){
//     //todo Map<String, dynamic> userData는 알아서 생성하자
//     List<List<List<String>>> list = [
//       _userResponses[index].recognitionCarryResults,
//       _userResponses[index].recognitionProgressResults,
//       _userResponses[index].recognitionAnswerResults];
//     List<int> lenList = _userResponses[index].matrixVolume;
//     Map<String, dynamic> userData = _bmEncode.responseToAnswerMap(list, lenList);
//     return _bmEncode.addUserDataToRequest(requestList[index], userData);
//   }
//
//   void sendRequest(int index) {
//     finishRawJsonForRequest(_userRequests, index);
//     Map<String,dynamic> data = _userRequests[index];
//
//     _bmEncode.sendAPIData(parentCategory, childCategory, data).catchError((e, stackTrace) {
//       print("❗ API 전송 실패: $e");
//       // 로그로 남기거나 나중에 재시도 큐에 넣는 것도 가능
//     });
//   }
//   MResponse createInitialResponse(MProblemMetadata data) {
//     return MResponse.init([], data.matrixVolume);
//   }
//   Future<void> prepareNextProblem() async {
//     final index = indexCounter;
//     final json = await fetchRawJsonFromResponse();
//
//     final mathData = fetchMathDataFromResponse(json, index);
//     final answer = fetchAnswerFromResponse(json, index);
//     final userResponse = createInitialResponse(mathData);
//
//     _mathDataList.add(mathData);
//     _answer.add(answer);
//     _userResponses.add(userResponse);
//     _problemKeys.add(GlobalKey<MProblemDisplayState>());
//     _userRequests.add(prepareRawJsonForRequest(json));
//     _isSent.add(false);
//   }
//   Future<void> _runRecognition() async {
//     await _problemKeys[indexCounter].currentState?.runRecognitionWithDisplay();
//   }
//
//   Future<void> _handleWrongAnswerHighlight() async {
//     await _problemKeys[indexCounter].currentState?.colorResponseBlocks();
//   }
//
//   void _playCorrectAnimation() {
//     _lottieController.reset();
//     _fadeController.reset();
//     _lottieController.forward();
//     _fadeController.forward();
//   }
//
//   Future<void> _sendResultOnceIfNeeded() async {
//     if (!_isSent[indexCounter]) {
//       finishRawJsonForRequest(_userRequests, indexCounter);
//       await _bmEncode.sendAPIData(
//           parentCategory, childCategory, _userRequests[indexCounter]);
//       _isSent[indexCounter] = true;
//     }
//   }
//
//   void _toggleInputState() {
//     _problemKeys[indexCounter].currentState?.toggleHasAnswerState();
//   }
//   void _activateAutoMode() {
//     setState(() {
//       _autoMode = true;
//     });
//     final currentState = _problemKeys[indexCounter].currentState;
//     if (currentState?.isAnswerCorrect() == true) {
//       _incrementCounter();
//     }
//   }
//   Future<void> _incrementCounter() async {
//     setState(() {
//       _isLoading = true;
//     });
//     final nextIndex = indexCounter + 1;
//     // 데이터를 먼저 추가
//     if (_userResponses.length <= nextIndex) {
//       await prepareNextProblem();
//     }
//     // indexCounter 증가는 데이터 준비가 끝난 뒤
//     setState(() {
//       indexCounter = nextIndex;
//       _isLoading = false;
//     });
//   }
//
//   void _decrementCounter() {
//     if (indexCounter <= 0) return;
//     setState(() {
//       indexCounter--;
//       md = _mathDataList[indexCounter]; // 기존 문제 재사용
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
//               _isLoading ||
//                   _answer.length <= indexCounter ||
//                   _userResponses.length <= indexCounter ||
//                   _problemKeys.length <= indexCounter
//                       ? const CircularProgressIndicator()
//                       : Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                             Column(
//                               children: [
//                                 MProblemDisplay(
//                                   key: _problemKeys[indexCounter],
//                                   problemMetaData: _mathDataList[indexCounter],
//                                   isTest: false,
//                                   correctResponse3DList: _answer[indexCounter],
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
//                                 //widget.categoryIndex == 602 ? SizedBox(height: 100) : SizedBox(height: 50),
//                                 SwitchButtonState(
//                                   onRunRecognition: () async {
//                                     await _runRecognition();
//                                     print("🔀Hi");
//
//                                     if (_problemKeys[indexCounter].currentState?.hasAnswer() ?? false) {
//                                       print("⏳Hi");
//                                       await _handleWrongAnswerHighlight();
//                                       print("🔧Hi");
//
//                                       _playCorrectAnimation();
//                                       await _sendResultOnceIfNeeded();
//                                       _toggleInputState();
//
//                                       setState(() {});
//                                     }
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
//
//   @override
//   void dispose() {
//     _lottieController.dispose();
//     _fadeController.dispose();
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
//
// }
//
