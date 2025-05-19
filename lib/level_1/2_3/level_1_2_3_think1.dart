import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../shared/provider/en_riverpod_provider.dart';
import '../../shared/widgets/en_result_popup.dart';

class LevelOneTwoThreeThink1 extends ConsumerStatefulWidget {
  final String problemCode;
  const LevelOneTwoThreeThink1({super.key, required this.problemCode});

  @override
  ConsumerState<LevelOneTwoThreeThink1> createState() => LevelOneTwoThreeThink1State();
}

class LevelOneTwoThreeThink1State extends ConsumerState<LevelOneTwoThreeThink1>
    with TickerProviderStateMixin {
  final ScreenshotController screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  late AnimationController submitController;
  late AnimationController resultController;
  late Animation<double> submitAnimation;
  late Animation<double> resultAnimation;
  late int childId;
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
  bool isShowResult = false;
  Map problemData = {};
  Map answerData = {};
  Map<String, dynamic> selectedAnswers = {};
  List<List<String>> fixedImageUrls = [];
  List<Map<String, String>> candidates = [];
  final Map<String, GlobalKey<HandwritingRecognitionZoneState>> zoneKeys = {};

  // 페이지 실행 시 작동하는 함수. 수정 필요 x
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
      isEnd = nextProblemCode.isEmpty;
    });
  }

  // 페이지를 나갈 때, 실행되는 함수. 수정 필요 x
  @override
  void dispose() {
    _timerController.dispose();
    submitController.dispose();
    resultController.dispose();
    isSubmitted = false;
    super.dispose();
  }

  // 페이지 실행 시, 문제 데이터를 불러오는 함수. 수정 필요 x
  Future<void> _loadQuestionData() async {
    try {
      final response = await _apiService.loadProblemData(problemCode);

      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      childId = childProfile['id'];

      final saved = await EnProblemService.loadProblemResults(problemCode, childId);
      ref.read(problemProgressProvider.notifier).setFromStorage(saved);
      final progress = ref.read(problemProgressProvider);
      debugPrint("📦 불러온 문제 기록: $progress");

      EnProblemService.saveContinueProblem(problemCode, childId);

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

      ref.read(problemProgressProvider.notifier).record(
        problemCode,
        isCorrect,
      );

      await EnProblemService.saveProblemResults(
        ref.read(problemProgressProvider),
        problemCode,
        childId,
      );

      setState(() => isSubmitted = true);
    } catch (e) {
      debugPrint('Submit error: $e');
    }
  }

  // 문제 데이터 받아온 후, 문제에 맞게 데이터 조작
  void _processProblemData(Map problemData) {}

  // 문제 푸는 로직 수행할때, seletedAnswers 데이터 넣는 로직
  Future<void> _processInputData() async {
    selectedAnswers.clear();

    for (final entry in zoneKeys.entries) {
      final recognized = await entry.value.currentState!.recognize();
      selectedAnswers[entry.key] = int.tryParse(recognized) ?? -1;
    }
  }

  // 정답 여부 체크(보통은 이거쓰면됨)
  Future<void> checkAnswer() async {
    await _processInputData();
    isCorrect = const DeepCollectionEquality().equals(
      answerData,
      selectedAnswers,
    );
    _submitAnswer();
  }

  // 문제푸는 스크린 이미지 서버로 전송. 수정 필요 x
  Future<void> submitActivity(BuildContext context) async {
    try {
      final imageBytes = await screenshotController.capture() as Uint8List;
      if (!context.mounted) return;

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

  // 팝업 조작 함수. 수정 필요 x
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

  // UI 담당
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppbarWidget(
        title: Text('알맞은 수 찾기'),
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
                                  questionText: '1. 알맞은 수를 찾아 빈칸에 적어 보세요.',
                                  questionTextSize: screenWidth * 0.03,
                                ),
                                // 여기에 문제 푸는 ui 및 삽입
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(9, (index) {
                                    final number = index + 1;
                                    return Container(
                                      width: screenWidth * 0.1,
                                      height: screenWidth * 0.08,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow[100],
                                        border: Border.all(
                                          color: Colors.lightBlue,
                                        ),
                                      ),
                                      child: Text(
                                        '$number',
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    );
                                  }),
                                ),
                                SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(problemData.length, (
                                    index,
                                  ) {
                                    final key = 'p${index + 1}';
                                    final values = List<int>.from(
                                      problemData[key],
                                    );
                                    final a = values[0];
                                    final b = values[1];
                                    final isGreater = index < 4;

                                    final prompt =
                                        isGreater
                                            ? ' $a보다 $b 큰 수는 '
                                            : ' $a보다 $b 작은 수는 ';

                                    zoneKeys.putIfAbsent(
                                      key,
                                      () =>
                                          GlobalKey<
                                            HandwritingRecognitionZoneState
                                          >(),
                                    );
                                    final zoneKey = zoneKeys[key]!;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Align(
                                        alignment:
                                            Alignment
                                                .centerLeft, // Ensure the Row aligns to the left
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                          ), // Add left padding here
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start, // Ensure children are left-aligned
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Number Badge
                                              Container(
                                                alignment: Alignment.center,
                                                width: screenWidth * 0.05,
                                                height: screenWidth * 0.05,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: Colors.purple[100],
                                                ),
                                                child: Text(
                                                  '${index + 1}', // Number Badge
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              // Question Text
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: Text(
                                                  prompt,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              // Handwriting Zone
                                              HandwritingRecognitionZone(
                                                key: zoneKey,
                                                width: screenWidth * 0.1,
                                                height: screenWidth * 0.1,
                                              ),
                                              const SizedBox(width: 6),
                                              const Text(
                                                '입니다.',
                                                style: TextStyle(fontSize: 24),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
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

                                      if (isSubmitted &&
                                          isCorrect == false) ...[
                                        ButtonWidget(
                                          height: screenHeight * 0.035,
                                          width: screenWidth * 0.18,
                                          buttonText: "제출하기",
                                          fontSize: screenWidth * 0.02,
                                          borderRadius: 10,
                                          onPressed: () async {
                                            await checkAnswer(); // ✅ correctly awaited
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
                                          onPressed: isEnd ?
                                              () => showResult() : () => onNextPressed(),
                                        ),
                                      ],

                                      if (isSubmitted && isCorrect == true)
                                        ButtonWidget(
                                          height: screenHeight * 0.035,
                                          width: screenWidth * 0.18,
                                          buttonText: isEnd ? "학습종료" : "다음문제",
                                          fontSize: screenWidth * 0.02,
                                          borderRadius: 10,
                                          onPressed: isEnd ?
                                              () => showResult() : () => onNextPressed(),
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
                                    result: getResult(),
                                    end: () async => onNextPressed()
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if(isShowResult)
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
                                      scaleAnimation: const AlwaysStoppedAnimation(1.0),
                                      result: getResult(),
                                      end: () async => end()
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              ),
    );
  }
}
