import 'dart:convert';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/level_1/shared/widgets/question_box_String.dart';
import 'package:nansan_flutter/modules/level_api/models/submit_request.dart';
import 'package:nansan_flutter/modules/level_api/services/problem_api_service.dart';
import 'package:nansan_flutter/level_1/shared/widgets/question_box.dart';
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
import '../../../shared/widgets/en_result_popup.dart';

class LevelOneOneThreeMain2 extends ConsumerStatefulWidget {
  final String problemCode;
  const LevelOneOneThreeMain2({super.key, required this.problemCode});

  @override
  ConsumerState<LevelOneOneThreeMain2> createState() =>
      _LevelOneOneThreeMain2State();
}

class _LevelOneOneThreeMain2State extends ConsumerState<LevelOneOneThreeMain2>
    with TickerProviderStateMixin {
  // 필수코드
  final ScreenshotController screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  int childId = 0;
  int? elapsedSeconds;
  int current = 1;
  int total = 1;
  String nextProblemCode = 'enlv1s1c3jy3';
  String problemCode = 'enlv1s1c3jy2';
  bool isSubmitted = false;
  bool isCorrect = false;
  bool showSubmitPopup = false;
  bool isEnd = false;
  bool isLoading = true;
  bool isShowResult = false;
  Map<String, dynamic> problemData = {};
  Map<String, dynamic> answerData = {};
  List<String> selectedAnswers = ['0','0','0','0'];
  late AnimationController submitController;
  late AnimationController resultController;
  late Animation<double> submitAnimation;
  late Animation<double> resultAnimation;

  // 옵션
  List<String> problem1Option = ['0','0','0'];
  List<String> problem2Option = ['0','0','0'];
  List<String> problem3Option = ['0','0','0'];
  List<String> problem4Option = ['0','0','0'];

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

    submitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: submitController, curve: Curves.elasticOut),
    );
    resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: resultController, curve: Curves.elasticOut),
    );

    // 비동기 로직 실행 후 UI 업데이트
    _loadQuestionData().then((_) {
      setState(() {
        isLoading = false;
      });
      _timerController.start();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timerController.dispose();
    submitController.dispose();
    resultController.dispose();
    isSubmitted = false;
    isEnd = nextProblemCode.isEmpty;
  }

  // problemcode에 따라 데이터 호출하는 함수
  Future<void> _loadQuestionData() async {
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
        // problem과 answer 데이터 저장
        problemData = response.problem;
        answerData = response.answer;
        current = response.current;
        total = response.total;
        _processProblemData(problemData);
      });
    } catch (e) {
      debugPrint('Error loading question data: $e');
    }
  }

  // 문제별 문제데이터 처리파트
  void _processProblemData(problemData) {
    List<dynamic> p1 = problemData['p1']['candidates'];
    List<dynamic> p2 = problemData['p2']['candidates'];
    List<dynamic> p3 = problemData['p3']['candidates'];
    List<dynamic> p4 = problemData['p4']['candidates'];

    problem1Option = List<String>.from(p1) ;
    problem2Option = List<String>.from(p2) ;
    problem3Option = List<String>.from(p3) ;
    problem4Option = List<String>.from(p4) ;

    debugPrint('$problem1Option');
  }

  // 제출함수(제출하기 버튼 누를시 작동하도록 설정)
  Future<void> _submitAnswer() async {
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
      input: {"answer" : selectedAnswers},
    );

    try {
      // API 서비스 호출
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

  Future<void> checkAnswer() async {
    isCorrect = const DeepCollectionEquality().equals(
      answerData['answer'],
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

  void end() async {
    await EnProblemService.clearChapterProblem(childId, problemCode);
    Modular.to.pop();
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
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Screenshot(
                          controller: screenshotController,
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                NewHeaderWidget(
                                  headerText: '주요학습활동',
                                  headerTextSize: screenWidth * 0.028,
                                  subTextSize: screenWidth * 0.018,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                NewQuestionTextWidget(
                                  questionText:
                                      '2. 그림의 수를 세고, 알맞은 숫자 이름을 클릭하세요.',
                                  questionTextSize: screenWidth * 0.03,
                                ),
                                SizedBox(height: screenWidth * 0.03),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    QuestionBoxString(
                                      width: screenWidth,
                                      height: screenHeight,
                                      object: problemData['object'],
                                      number: problemData['p1']['number'],
                                      options: problem1Option,
                                      questionId: 0,
                                      onAnswerSelected: (questionId, selected) {
                                        setState(() {
                                          selectedAnswers[questionId] = selected;
                                        });
                                      },
                                      selectedAnswer: selectedAnswers[0],
                                    ),
                                    SizedBox(width: screenHeight * 0.03),
                                    QuestionBoxString(
                                      width: screenWidth,
                                      height: screenHeight,
                                      object: problemData['object'],
                                      number: problemData['p2']['number'],
                                      options: problem2Option,
                                      questionId: 1,
                                      onAnswerSelected: (questionId, selected) {
                                        setState(() {
                                          selectedAnswers[questionId] = selected;
                                        });
                                      },
                                      selectedAnswer: selectedAnswers[1],
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    QuestionBoxString(
                                      width: screenWidth,
                                      height: screenHeight,
                                      object: problemData['object'],
                                      number: problemData['p3']['number'],
                                      options: problem3Option,
                                      questionId: 2,
                                      onAnswerSelected: (questionId, selected) {
                                        setState(() {
                                          selectedAnswers[questionId] = selected;
                                        });
                                      },
                                      selectedAnswer: selectedAnswers[2],
                                    ),
                                    SizedBox(width: screenHeight * 0.03),
                                    QuestionBoxString(
                                      width: screenWidth,
                                      height: screenHeight,
                                      object: problemData['object'],
                                      number: problemData['p4']['number'],
                                      options: problem4Option,
                                      questionId: 3,
                                      onAnswerSelected: (questionId, selected) {
                                        setState(() {
                                          selectedAnswers[questionId] = selected;
                                        });
                                      },
                                      selectedAnswer: selectedAnswers[3],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            EnProgressBarWidget(current: current, total: total),
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
