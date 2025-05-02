import 'dart:convert';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/level_1/2_2/widgets/dynamic_number_row.dart';
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

import '../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

class LevelOneTwoThreeMain1 extends StatefulWidget {
  final String problemCode;
  const LevelOneTwoThreeMain1({super.key, required this.problemCode});

  @override
  State<LevelOneTwoThreeMain1> createState() => _LevelOneTwoThreeMain1State();
}

class _LevelOneTwoThreeMain1State extends State<LevelOneTwoThreeMain1>
    with TickerProviderStateMixin {
  // 필수코드
  final ScreenshotController screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  int childId = 0;
  int? elapsedSeconds;
  int current = 1;
  int total = 1;
  String nextProblemCode = '';
  String problemCode = 'enlv1s2c3jy1';
  bool isSubmitted = false;
  bool isCorrect = false;
  bool isEnd = true;
  bool isLoading = true;
  bool showSubmitPopup = false;
  Map<String, List<int>> problemData = {};
  Map<String, dynamic> answerData = {};
  Map<String, dynamic> selectedAnswers = {};
  late AnimationController submitController;
  late Animation<double> submitAnimation;
  final Map<String, GlobalKey<HandwritingRecognitionZoneState>> zoneKeys = {};

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
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timerController.dispose();
    isSubmitted = false;
  }

  // problemcode에 따라 데이터 호출하는 함수
  Future<void> _loadQuestionData() async {
    try {
      final response = await _apiService.loadProblemData(problemCode);

      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      childId = childProfile['id'];
      EnProblemService.saveContinueProblem(widget.problemCode, childId);

      setState(() {
        nextProblemCode = response.nextProblemCode;
        problemCode = response.problemCode;
        current = response.current;
        total = response.total;

        problemData = response.problem.map<String, List<int>>(
          (key, value) => MapEntry(key, List<int>.from(value)),
        );
        answerData = response.answer;
        selectedAnswers = response.problem;
      });
    } catch (e) {
      debugPrint('Error loading question data: $e');
    }
  }

  // 제출함수(제출하기 버튼 누를시 작동하도록 설정)
  Future<void> submitAnswer() async {
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
      setState(() {
        isSubmitted = true;
      });
    } catch (e) {
      debugPrint('답변 제출 중 오류 발생: $e');
      // 오류 처리 (필요에 따라 사용자에게 알림)
    }
  }

  // void _processInputData() {}

  // 정답 체크하는 함수. 정답 체크로직 구현 필요.
  Future<void> checkAnswer() async {
    await recognizeAll();
    // _processInputData();
    isCorrect = DeepCollectionEquality().equals(answerData, selectedAnswers);
    submitAnswer();
  }

  Future<void> submitActivity(BuildContext context) async {
    await recognizeAll();
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

  Future<void> recognizeAll() async {
    for (final entry in zoneKeys.entries) {
      final key = entry.key; // e.g. "p1-2"
      final zoneKey = entry.value;
      final state = zoneKey.currentState;

      // Skip the entry if state is null or the widget is unmounted
      if (state == null) {
        debugPrint("Skipping $key — state is null");
        continue;
      }

      try {
        final recognized = await state.recognize();
        final parts = key.split('-');
        final rowKey = parts[0];
        final index = int.parse(parts[1]);

        final row = List<int>.from(selectedAnswers[rowKey]);
        row[index] = int.tryParse(recognized) ?? -1;
        selectedAnswers[rowKey] = row;
      } catch (e) {
        debugPrint("Recognition failed for $key: $e");
      }
    }
  }

  void onNextPressed() {
    final nextCode = nextProblemCode;
    if (nextCode.isEmpty) {
      debugPrint("📌 다음 문제가 없습니다.");
      EnProblemService.clearChapterProblem(childId, widget.problemCode);
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
                              headerText: '주요학습활동',
                              headerTextSize: screenWidth * 0.028,
                              subTextSize: screenWidth * 0.018,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            NewQuestionTextWidget(
                              questionText: '1. 빠진 수를 바르게 적어 보세요.',
                              questionTextSize: screenWidth * 0.025,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(3, (index) {
                                final key = 'p${index + 1}';
                                final data = problemData[key] ?? [];

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: screenHeight * 0.02,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          width: screenWidth * 0.05,
                                          height: screenWidth * 0.05,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            color: Colors.purple[100],
                                          ),
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                            ),
                                          ),
                                        ),
                                        DynamicNumberRow(
                                          rowId: key,
                                          data: data,
                                          zoneKeys: zoneKeys,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
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
                                              await checkAnswer();
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
                                              await submitActivity(context);
                                              checkAnswer();
                                              setState(() {
                                                showSubmitPopup = true;
                                              });
                                              await submitController.forward();
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
