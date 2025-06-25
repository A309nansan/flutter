import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/level_1/1_3/widgets/click_and_drag_widget.dart';
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
import 'package:nansan_flutter/shared/widgets/sample_popup.dart';
import 'package:nansan_flutter/shared/widgets/successful_popup.dart';
import 'package:screenshot/screenshot.dart';
import 'package:collection/collection.dart';
import '../../../shared/provider/en_riverpod_provider.dart';
import '../../../shared/widgets/en_result_popup.dart';

class LevelOneOneThreeThink extends ConsumerStatefulWidget {
  final String problemCode;

  const LevelOneOneThreeThink({super.key, required this.problemCode});

  @override
  ConsumerState createState() => _LevelOneOneThreeThinkState();
}

class _LevelOneOneThreeThinkState extends ConsumerState<LevelOneOneThreeThink>
    with TickerProviderStateMixin {

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
  bool isShowResult = false;
  bool isShowSample = false;
  Map problemData = {};
  Map answerData = {};
  Map<String, List<int>> selectedAnswers = {"answer": <int>[]};
  late AnimationController submitController;
  late AnimationController resultController;
  late AnimationController popupController;
  late Animation<double> submitAnimation;
  late Animation<double> resultAnimation;
  late Animation<double> popupAnimation;

  late String object;
  late int p1Data;
  late int p2Data;
  late int p3Data;
  List<int> selectNumber = [0,0,0];

  @override
  void initState() {
    super.initState();
    submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    popupController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
    );

    submitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: submitController, curve: Curves.elasticOut),
    );
    resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: resultController, curve: Curves.elasticOut),
    );
    popupAnimation = CurvedAnimation(
        parent: popupController,
        curve: Curves.elasticOut,
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
    submitController.dispose();
    resultController.dispose();
    isSubmitted = false;
  }

  Future _loadQuestionData() async {
    try {
      final response = await _apiService.loadProblemData(problemCode);

      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      childId = childProfile['id'];

      final saved = await EnProblemService.loadProblemResults(
        problemCode,
        childId,
      );
      ref.read(problemProgressProvider.notifier).setFromStorage(saved);

      EnProblemService.saveContinueProblem(problemCode, childId);

      setState(() {
        nextProblemCode = response.nextProblemCode;
        problemCode = response.problemCode;
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

  Future _submitAnswer() async {
    if (isSubmitted) return;

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
      await _apiService.submitAnswer(jsonEncode(submitRequest.toJson()));

      ref.read(problemProgressProvider.notifier).record(problemCode, isCorrect);

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
    object = problemData['object'];
    p1Data = problemData['problem'][0];
    p2Data = problemData['problem'][1];
    p3Data = problemData['problem'][2];
  }

  void _processInputData(int identifier, int count) {
    setState(() {
      selectNumber[identifier] = count;
      selectedAnswers["answer"] = selectNumber;
    });
  }

  void checkAnswer() {
    _timerController.stop();

    isCorrect = const DeepCollectionEquality().equals(
      answerData,
      selectedAnswers,
    );

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
      await EnProblemService.saveProblemResults(progress, problemCode, childId);

      await EnProblemService.clearChapterProblem(childId, problemCode);
      showResult();
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

  Future<Map<String, dynamic>> getResult() async {
    final saved = await EnProblemService.loadProblemResults(
      problemCode,
      childId,
    );

    final correctCount = saved.values.where((v) => v == true).length;
    final totalCount = saved.length;

    final result = {
      "correct": correctCount,
      "wrong": totalCount - correctCount,
    };

    return result;
  }

  void closeSubmit() {
    submitController.reverse().then((_) {
      setState(() {
        showSubmitPopup = false;
      });
    });
  }

  void showResult() async {
    setState(() {
      isShowResult = true;
    });
    resultController.forward(from: 0);
  }

  void showSample() {
    setState(() {
      isShowSample = true;
    });
    popupController.forward(from: 0.0);
  }

  void closeSample() {
    popupController.reverse().then((_) {
      setState(() {
        isShowSample = false;
      });
    });
  }

  void end() async {
    await EnProblemService.clearChapterProblem(childId, problemCode);
    Modular.to.pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (isLoading) {
      return const Scaffold(
        appBar: AppbarWidget(title: null),
        body: Center(child: EnProblemSplashScreen()),
      );
    }

    final problemImages = [p1Data, p2Data, p3Data];

    return Scaffold(
      appBar: AppbarWidget(
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40.0),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Screenshot(
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
                          Row(
                            children: [
                              Expanded(
                                child: NewQuestionTextWidget(
                                  questionText: '그림이 나타내는 수만큼 네모를 클릭하여 채워보세요!',
                                  questionTextSize: screenWidth * 0.03,
                                ),
                              ),
                              IconButton(
                                onPressed: showSample,
                                icon: Icon(
                                  Icons.lightbulb,
                                  size: 30,
                                  color: Colors.yellow,
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(77),
                                      blurRadius: 3,
                                      offset: const Offset(1, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return Padding(
                                padding: EdgeInsets.only(top: screenHeight * 0.02),
                                child: Container(
                                  width: screenWidth * 0.9,
                                  height: screenHeight * 0.2,
                                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.055),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black38,
                                            offset: const Offset(0, 4),
                                            blurRadius: 4.0
                                        )
                                      ]
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: screenWidth * 0.25,
                                          height: screenHeight * 0.25,
                                          child: Image.asset('assets/images/number/$object/${problemImages[index]}.png',)
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.5,
                                        height: screenHeight * 0.13,
                                        child: Center(
                                          child: ClickAndDragWidget(
                                            filledCount: (selectedAnswers["answer"] != null && selectedAnswers["answer"]!.length > index + 1)
                                                ? selectedAnswers["answer"]![index + 1]
                                                : 0,
                                            onChanged: (count) {
                                              _processInputData(index, count);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: screenHeight * 0.02),
                        child: EnProgressBarWidget(current: current, total: total),
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
                                            submitController.forward(),
                                            showSubmitPopup = true,
                                            submitActivity(context),
                                            checkAnswer(),
                                          },
                                ),

                              if (isSubmitted && isCorrect == false) ...[
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
                                  onPressed:
                                      isEnd
                                          ? () => showResult()
                                          : () => onNextPressed(),
                                ),
                              ],

                              if (isSubmitted && isCorrect == true)
                                ButtonWidget(
                                  height: screenHeight * 0.035,
                                  width: screenWidth * 0.18,
                                  buttonText: isEnd ? "학습종료" : "다음문제",
                                  fontSize: screenWidth * 0.02,
                                  borderRadius: 10,
                                  onPressed:
                                      isEnd
                                          ? () => showResult()
                                          : () => onNextPressed(),
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
          if(isShowSample)
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: closeSample,
                  child: FadeTransition(
                    opacity: popupAnimation,
                    child: Container(
                      color: Colors.black54,
                      child: ScaleTransition(
                        scale: popupAnimation,
                        child: SamplePopup(
                          scaleAnimation: const AlwaysStoppedAnimation(1.0),
                          onClose: closeSample,
                          desc:
                          "\u{1F4A1} 그림이 나타내는 수만큼 네모를 클릭하거나 드래그해 보세요.",
                          image: "assets/images/level1_1_3_think_sample.png",
                        ),
                      ),
                    ),
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
                            result: getResult(),
                            end: () async => onNextPressed(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (isShowResult)
            Positioned.fill(
              child: Stack(
                children: [
                  Container(color: Colors.black54),
                  Center(
                    child: FadeTransition(
                      opacity: resultAnimation,
                      child: ScaleTransition(
                        scale: resultAnimation,
                        child: Material(
                          type: MaterialType.transparency,
                          child: EnResultPopup(
                            scaleAnimation:
                                const AlwaysStoppedAnimation(1.0),
                            result: getResult(),
                            end: () async => end(),
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
