import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/level_1/2_3/widgets/clickable_widget_123main2.dart';
import 'package:nansan_flutter/modules/level_api/models/submit_request.dart';
import 'package:nansan_flutter/modules/level_api/services/problem_api_service.dart';
import 'package:nansan_flutter/shared/controllers/timer_controller.dart';
import 'package:nansan_flutter/shared/services/en_problem_service.dart';
import 'package:nansan_flutter/shared/services/image_service.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:nansan_flutter/shared/widgets/appbar_widget.dart';
import 'package:nansan_flutter/shared/widgets/button_widget.dart';
import 'package:nansan_flutter/shared/widgets/en_problem_splash_screen.dart';
import 'package:nansan_flutter/shared/widgets/en_progress_bar_widget.dart';
import 'package:nansan_flutter/shared/widgets/new_header_widget.dart';
import 'package:nansan_flutter/shared/widgets/new_question_text.dart';
import 'package:nansan_flutter/shared/widgets/successful_popup.dart';
import 'package:screenshot/screenshot.dart';
import 'package:collection/collection.dart';

class LevelOneTwoThreeMain2 extends StatefulWidget {
  final String problemCode;
  const LevelOneTwoThreeMain2({super.key, required this.problemCode});

  @override
  State<LevelOneTwoThreeMain2> createState() => _LevelOneTwoThreeMain2State();
}

class _LevelOneTwoThreeMain2State extends State<LevelOneTwoThreeMain2>
    with TickerProviderStateMixin {
  final ScreenshotController screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  late AnimationController submitController;
  late Animation<double> submitAnimation;
  late int childId = 1;
  late int current;
  late int total;
  late int elapsedSeconds;
  late String problemCode = widget.problemCode;
  late String nextProblemCode;
  bool isSubmitted = false;
  bool isCorrect = false;
  bool showSubmitPopup = false;
  bool isEnd = false;
  bool isLoading = true;
  Map problemData = {};
  Map answerData = {};
  Map<String, dynamic> selectedAnswers = {};
  List<List<String>> fixedImageUrls = [];
  List<Map<String, String>> candidates = [];

  //페이지별 변수
  String exampleData = '';
  List<String> problemTexts = [];
  String p1Data = '';
  String p2Data = '';
  String p3Data = '';
  String p4Data = '';
  String p5Data = '';
  String p6Data = '';
  String p7Data = '';
  String p8Data = '';
  String p9Data = '';

  //정렬코드
  Widget _buildButtonRow(List<String> identifiers, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: identifiers
          .mapIndexed((i, id) => Row(
        children: [
          ClickableWidget123Main2(
            identifier: id,
            problemNum: id.replaceAll(RegExp(r'[^0-9]'), ''), // 숫자만 추출
            onClickCountChanged:
            _processInputData,
          ),
          if (i != identifiers.length - 1)
            SizedBox(width: screenWidth * 0.08),
        ],
      ))
          .expand((e) => e.children)
          .toList(),
    );
  }


  // 페이지 실행 시 작동하는 함수. 수정 필요 x
  @override
  void initState() {
    super.initState();
    submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    submitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: submitController, curve: Curves.elasticOut),
    );
    // 비동기 로직 실행 후 UI 업데이트
    _loadQuestionData().then((_) {
      setState(() {
        isLoading = false;
      });
      _timerController.start();
      isEnd = nextProblemCode.isEmpty;
    });
  }

  // 페이지를 나갈 때, 실행되는 함수. 수정 필요 x
  @override
  void dispose() {
    _timerController.dispose();
    isSubmitted = false;
    super.dispose();
  }

  // 페이지 실행 시, 문제 데이터를 불러오는 함수. 수정 필요 x
  Future<void> _loadQuestionData() async {
    try {
      final response = await _apiService.loadProblemData(problemCode);
      setState(() {
        nextProblemCode = response.nextProblemCode;
        problemData = response.problem;
        answerData = response.answer;
        current = response.current;
        total = response.total;
      });
      _processProblemData(problemData);
    } catch (e) {
      debugPrint('Error loading question data: $e');
    }
  }

  // 문제 제출할때 함수. 수정 필요 x
  Future<void> _submitAnswer() async {
    if (isSubmitted) return;
    final submitRequest = SubmitRequest(
      childId: childId,
      problemCode: problemCode,
      dateTime: DateTime.now().toIso8601String(),
      solvingTime: _timerController.elapsedSeconds,
      isCorrected: isCorrect,
      problem: problemData,
      answer: answerData,
      input: selectedAnswers,
    );

    try {
      await _apiService.submitAnswer(jsonEncode(submitRequest.toJson()));
      setState(() => isSubmitted = true);
    } catch (e) {
      debugPrint('Submit error: $e');
    }
  }

  // 문제 데이터 받아온 후, 문제에 맞게 데이터 조작
  //json추가후 확인할것
  // void _processProblemData(Map problemData) {
  //   //9문항이므로 9개로 처리
  //   problemTexts = List.generate(9, (index) {
  //     final key = 'p${index + 1}';
  //     return problemData[key] ?? '';
  //   });
  //
  //   debugPrint('문제 텍스트 리스트: $problemTexts');
  // }
  void _processProblemData(problemData) {
    exampleData = problemData['example'];
    p1Data = problemData['p1'];
    p2Data = problemData['p2'];
    p3Data = problemData['p3'];
    p4Data = problemData['p4'];
    p5Data = problemData['p5'];
    p6Data = problemData['p6'];
    p7Data = problemData['p7'];
    p8Data = problemData['p8'];
    p9Data = problemData['p9'];

    debugPrint('문제 텍스트 리스트: $p1Data\n$p2Data\n$p3Data\n$p4Data\n$p5Data\n$p6Data\n$p7Data\n$p8Data\n$p9Data\n');
  }

  // 문제 푸는 로직 수행할때, seletedAnswers 데이터 넣는 로직
  void _processInputData(String identifier, int count) {
    setState(() {
      selectedAnswers[identifier] = count;
    });
    debugPrint('$selectedAnswers');
  }

  // 정답 여부 체크(보통은 이거쓰면됨)
  void checkAnswer() {

    isCorrect = answerData.entries.every((entry) {
      return selectedAnswers[entry.key] == entry.value;
    });

    _submitAnswer();
  }

  // 문제푸는 스크린 이미지 서버로 전송. 수정 필요 x
  Future<void> submitActivity(BuildContext context) async {
    try {
      final imageBytes = await screenshotController.capture() as Uint8List;
      if (!context.mounted) return;

      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      final childId = childProfile['id'];

      await ImageService.uploadImage(
        imageBytes: imageBytes,
        childId: childId,
        localDateTime: DateTime.now(),
      );
    } catch (e) {
      debugPrint("이미지 캡처 중 오류 발생: $e");
    }
  }

  // 다음페이지로 가는 함수. 수정 필요 x
  void onNextPressed() {
    final nextCode = nextProblemCode;
    if (nextCode.isEmpty) {
      debugPrint("📌 다음 문제가 없습니다.");
      Modular.to.pop();
      return;
    }

    try {
      final route = EnProblemService().getLevelPath(nextCode);
      Modular.to.pushReplacementNamed(route, arguments: nextCode);
    } catch (e) {
      debugPrint("⚠️ 경로 생성 중 오류: $e");
    }
  }

  // 팝업 조작 함수. 수정 필요 x
  void closeSubmit() {
    submitController.reverse().then((_) {
      setState(() {
        showSubmitPopup = false;
      });
    });
  }

  // UI 담당
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppbarWidget(
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40.0),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body:
      isLoading
          ? const Center(child: EnProblemSplashScreen())
          : Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Screenshot(
                    controller: screenshotController,
                    child: Column(
                      children: [
                        NewHeaderWidget(
                          headerText: '개념학습활동',
                          headerTextSize: screenWidth * 0.028,
                          subTextSize: screenWidth * 0.018,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        NewQuestionTextWidget(
                          questionText:
                          '숫자가 들어갈 알맞은 위치를 찾아 <보기>와 같이 O표 하세요.',
                          questionTextSize: screenWidth * 0.03,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        SizedBox(
                          height: screenHeight * 0.65,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildButtonRow(['p1', 'p2', 'p3'], screenWidth),
                                  SizedBox(height: screenWidth * 0.02),
                                  _buildButtonRow(['p4', 'p5', 'p6'], screenWidth),
                                  SizedBox(height: screenWidth * 0.02),
                                  _buildButtonRow(['p7', 'p8', 'p9'], screenWidth),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      EnProgressBarWidget(
                        current: current,
                        total: total,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: screenHeight * 0.02,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Row(
                            key: ValueKey<String>(
                              '${isSubmitted}_$isCorrect',
                            ),
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isSubmitted)
                                ButtonWidget(
                                  height: screenHeight * 0.035,
                                  width: screenWidth * 0.18,
                                  buttonText: "제출하기",
                                  fontSize: screenWidth * 0.02,
                                  borderRadius: 10,
                                  onPressed: () async {
                                    if (isSubmitted) return;
                                    checkAnswer();
                                    setState(() {
                                      showSubmitPopup = true;
                                    });
                                    submitController.forward();
                                    await submitActivity(context);
                                  },
                                ),
                              if (isSubmitted &&
                                  isCorrect == false) ...[
                                ButtonWidget(
                                  height: screenHeight * 0.035,
                                  width: screenWidth * 0.18,
                                  buttonText: "제출하기",
                                  fontSize: screenWidth * 0.02,
                                  borderRadius: 10,
                                  onPressed: () async {
                                    checkAnswer(); //
                                    setState(() {
                                      showSubmitPopup = true;
                                    });
                                    submitController
                                        .forward(); // ✅ called after the popup flag is set
                                  },
                                ),
                                const SizedBox(width: 20),
                                ButtonWidget(
                                  height: screenHeight * 0.035,
                                  width: screenWidth * 0.18,
                                  buttonText: isEnd ? "학습종료" : "다음문제",
                                  fontSize: screenWidth * 0.02,
                                  borderRadius: 10,
                                  onPressed: () => onNextPressed(),
                                ),
                              ],

                              if (isSubmitted && isCorrect == true)
                                ButtonWidget(
                                  height: screenHeight * 0.035,
                                  width: screenWidth * 0.18,
                                  buttonText: isEnd ? "학습종료" : "다음문제",
                                  fontSize: screenWidth * 0.02,
                                  borderRadius: 10,
                                  onPressed: () => onNextPressed(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (showSubmitPopup)
            Positioned.fill(
              child: Stack(
                children: [
                  Container(color: Colors.black54),
                  Center(
                    child: FadeTransition(
                      opacity: submitAnimation,
                      child: ScaleTransition(
                        scale: submitAnimation,
                        child: Material(
                          type: MaterialType.transparency,
                          child: SuccessfulPopup(
                            scaleAnimation:
                            const AlwaysStoppedAnimation(1.0),
                            isCorrect: isCorrect,
                            customMessage:
                            isCorrect ? "🎉 정답이에요!" : "틀렸어요...",
                            isEnd: isEnd,
                            closePopup: closeSubmit,
                            onClose:
                            isCorrect
                                ? () async => onNextPressed()
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
