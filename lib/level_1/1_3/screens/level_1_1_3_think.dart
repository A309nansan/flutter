import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/level_1/1_3/widgets/Example_widget_113.dart';
import 'package:nansan_flutter/level_1/1_3/widgets/clickable_widget_113.dart';
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

import '../../../shared/provider/EnRiverPodProvider.dart';

class LevelOneOneThreeThink extends ConsumerStatefulWidget {
  final String problemCode;

  const LevelOneOneThreeThink({super.key, required this.problemCode});

  @override
  ConsumerState createState() => _LevelOneOneThreeThinkState();
}

class _LevelOneOneThreeThinkState extends ConsumerState<LevelOneOneThreeThink>
    with TickerProviderStateMixin {
  // 필수코드
  final ScreenshotController screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  int childId = 0;
  int? elapsedSeconds;
  int current = 1;
  int total = 1;
  String nextProblemCode = 'enlv1s1c3jy1';
  String problemCode = 'enlv1s1c3gn1';
  bool isSubmitted = false;
  bool isCorrect = false;
  bool showSubmitPopup = false;
  bool isEnd = false;
  bool isLoading = true;
  Map problemData = {};
  Map answerData = {};
  Map<String, int> selectedAnswers = {"p1": 0, "p2": 0, "p3": 0};
  late AnimationController submitController;
  late Animation<double> submitAnimation;

  //페이지별 변수
  String exampleData = '';
  String p1Data = '';
  String p2Data = '';
  String p3Data = '';

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

  @override
  void dispose() {
    super.dispose();
    _timerController.dispose();
    isSubmitted = false;
  }

  // problemcode에 따라 데이터 호출하는 함수
  Future _loadQuestionData() async {
    try {
      final response = await _apiService.loadProblemData(problemCode);

      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      childId = childProfile['id'];

      final saved = await EnProblemService.loadProblemResults(problemCode, childId);
      ref.read(problemProgressProvider.notifier).setFromStorage(saved);

      EnProblemService.saveContinueProblem(problemCode, childId);

      setState(() {
        nextProblemCode = response.nextProblemCode;
        problemCode = response.problemCode;
        // problem과 answer 데이터 저장
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

  // 제출함수(제출하기 버튼 누를시 작동하도록 설정)
  Future _submitAnswer() async {
    if (isSubmitted) return; // 이미 제출된 경우 중복 제출 방지

    // 현재 날짜와 시간 (ISO 8601 형식)
    final now = DateTime.now();
    final dateTime = now.toIso8601String();

    // SubmitRequest 객체 생성
    final submitRequest = SubmitRequest(
      childId: childId,
      problemCode: problemCode,
      dateTime: dateTime,
      solvingTime: _timerController.elapsedSeconds,
      isCorrected: isCorrect,
      problem: problemData,
      answer: answerData,
      input: selectedAnswers,
    );

    try {
      // API 서비스 호출
      await _apiService.submitAnswer(jsonEncode(submitRequest.toJson()));

      ref.read(problemProgressProvider.notifier).record(
        problemCode,
        isCorrect,
      );

      await EnProblemService.saveProblemResults(
        ref.read(problemProgressProvider),
        problemCode,
        childId,
      );

      setState(() {
        isSubmitted = true;
      });
    } catch (e) {
      debugPrint('답변 제출 중 오류 발생: $e');
    }
  }

  void _processProblemData(problemData) {
    exampleData = problemData['example'];
    p1Data = problemData['p1'];
    p2Data = problemData['p2'];
    p3Data = problemData['p3'];
  }

  // 수정: 제출 시 최종 입력 데이터 처리
  void _processInputData(String identifier, int count) {
    setState(() {
      selectedAnswers[identifier] = count;
    });
  }

  void checkAnswer() {
    _timerController.stop();

    isCorrect = answerData.entries.every((entry) {
      return selectedAnswers[entry.key] == entry.value;
    });

    _submitAnswer();
  }

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

  void onNextPressed() async {
    final nextCode = nextProblemCode;
    if (nextCode.isEmpty) {
      debugPrint("📌 다음 문제가 없습니다.");
      final progress = ref.read(problemProgressProvider);
      await EnProblemService.saveProblemResults(
        progress,
        problemCode,
        childId,
      );

      await EnProblemService.clearChapterProblem(childId, problemCode);
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

  void closeSubmit() {
    submitController.reverse().then((_) {
      setState(() {
        showSubmitPopup = false;
      });
    });
  }

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
                    child: Screenshot(
                      controller: screenshotController,
                      child: Container(
                        color: Colors.white,
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
                                  '<보기>와 같이 그림이 나타내는 수만큼 네모를 클릭해 보세요!',
                              questionTextSize: screenWidth * 0.03,
                            ),
                            ExampleWidget113(exampleData: exampleData),
                            SizedBox(height: screenHeight * 0.02),
                            ClickableWidget113(
                              imageUrl: p1Data,
                              identifier: 'p1', // p1 식별자 전달
                              onClickCountChanged:
                                  _processInputData, // 콜백 함수 전달
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            ClickableWidget113(
                              imageUrl: p2Data,
                              identifier: 'p2', // p2 식별자 전달
                              onClickCountChanged:
                                  _processInputData, // 콜백 함수 전달
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            ClickableWidget113(
                              imageUrl: p3Data,
                              identifier: 'p3',
                              onClickCountChanged:
                                  _processInputData, // 콜백 함수 전달
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
                                            onPressed:
                                                (isSubmitted)
                                                    ? null
                                                    : () => {
                                                      submitController
                                                          .forward(),
                                                      showSubmitPopup = true,
                                                      submitActivity(context),
                                                      checkAnswer(),
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
                                            onPressed:
                                                () => {
                                                  setState(() {
                                                    checkAnswer();
                                                    showSubmitPopup = true;
                                                  }),
                                                  submitController.forward(),
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
