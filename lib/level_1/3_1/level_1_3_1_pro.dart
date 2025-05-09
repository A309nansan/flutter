import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/level_1/3_1/widgets/count_widget.dart';
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
import 'package:nansan_flutter/shared/provider/EnRiverPodProvider.dart';

import '../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';

// ✅ 상태변경 1. StatefulWidget -> ConsumerStatefulWidget
class LevelOneThreeOnePro extends ConsumerStatefulWidget {
  final String problemCode;
  const LevelOneThreeOnePro({super.key, required this.problemCode});

  @override
  // ✅ 상태변경 2. State -> ConsumerState
  ConsumerState<LevelOneThreeOnePro> createState() => LevelOneThreeOneProState();
}

// ✅ 상태변경 3. State -> ConsumerState
class LevelOneThreeOneProState extends ConsumerState<LevelOneThreeOnePro> with TickerProviderStateMixin {
  final ScreenshotController screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  late AnimationController submitController;
  late Animation<double> submitAnimation;
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
  Map problemData = {};
  Map answerData = {};
  Map<String, dynamic> selectedAnswers = {};
  List<List<String>> fixedImageUrls = [];
  List<Map<String, String>> candidates = [];
  final Map<String, GlobalKey<HandwritingRecognitionZoneState>> zoneKeys = {
    'p1-1': GlobalKey<HandwritingRecognitionZoneState>(),
    'p1-2': GlobalKey<HandwritingRecognitionZoneState>(),
    'p2-1': GlobalKey<HandwritingRecognitionZoneState>(),
    'p2-2': GlobalKey<HandwritingRecognitionZoneState>(),
    'p3-1': GlobalKey<HandwritingRecognitionZoneState>(),
    'p3-2': GlobalKey<HandwritingRecognitionZoneState>(),
    'p4-1': GlobalKey<HandwritingRecognitionZoneState>(),
    'p4-2': GlobalKey<HandwritingRecognitionZoneState>(),
  };

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

      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      childId = childProfile['id'];
      // ✅ 저장된 문제 이어풀기 불러오기
      final saved = await EnProblemService.loadProblemResults(problemCode, childId);
      ref.read(problemProgressProvider.notifier).setFromStorage(saved);

      // ✅ 저장된 이어풀기 기록 확인용(확인 완료 시 지우기)
      final progress = ref.read(problemProgressProvider);
      debugPrint("📦 불러온 문제 기록: $progress");

      // ✅ 문제 이어풀기 기록 저장
      EnProblemService.saveContinueProblem(problemCode, childId);

      // setState(() {
      //   nextProblemCode = response.nextProblemCode;
      //   problemData = response.problem;
      //   answerData = response.answer;
      //   current = response.current;
      //   total = response.total;
      // });
      setState(() {
        nextProblemCode = response.nextProblemCode;
        problemData = {
          "p1": [ 2, 3 ],
          "p2": [ 4, 5 ],
          "p3": [ 8, 9 ],
          "p4": [ 6, 7 ],
        };
        answerData = {
          "a1": [ 2, 3 ],
          "a2": [ 4, 5 ],
          "a3": [ 8, 9 ],
          "a4": [ 6, 7 ],
        };
        selectedAnswers = {
          "a1": [ 0, 0 ],
          "a2": [ 0, 0 ],
          "a3": [ 0, 0 ],
          "a4": [ 0, 0 ],
        };
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
    final childProfileJson = await SecureStorageService.getChildProfile();
    final childProfile = jsonDecode(childProfileJson!);
    final childId = childProfile['id'];

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

      // ✅ 문제 제출 시 제출 결과 Riverpod(Provider)
      ref.read(problemProgressProvider.notifier).record(
        problemCode,
        isCorrect,
      );

      // ✅ 문제 제출 시 제출 결과 storage에 저장
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
    selectedAnswers["a1"][0] = int.tryParse(await zoneKeys["p1-1"]!.currentState!.recognize()) ?? 0;
    selectedAnswers["a1"][1] = int.tryParse(await zoneKeys["p1-2"]!.currentState!.recognize()) ?? 0;
    selectedAnswers["a2"][0] = int.tryParse(await zoneKeys["p2-1"]!.currentState!.recognize()) ?? 0;
    selectedAnswers["a2"][1] = int.tryParse(await zoneKeys["p2-2"]!.currentState!.recognize()) ?? 0;
    selectedAnswers["a3"][0] = int.tryParse(await zoneKeys["p3-1"]!.currentState!.recognize()) ?? 0;
    selectedAnswers["a3"][1] = int.tryParse(await zoneKeys["p3-2"]!.currentState!.recognize()) ?? 0;
    selectedAnswers["a4"][0] = int.tryParse(await zoneKeys["p4-1"]!.currentState!.recognize()) ?? 0;
    selectedAnswers["a4"][1] = int.tryParse(await zoneKeys["p4-2"]!.currentState!.recognize()) ?? 0;
  }

  // 정답 여부 체크(보통은 이거쓰면됨)
  Future<void> checkAnswer() async {
    await _processInputData();
    debugPrint(selectedAnswers.toString());
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

  // ✅ 이어풀기 추가 따른 다음 페이지로 가는 함수 변경
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
                          headerText: '심화학습활동',
                          headerTextSize: screenWidth * 0.028,
                          subTextSize: screenWidth * 0.018,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        NewQuestionTextWidget(
                          questionText:
                          '동그라미를 세고, 수직선에 알맞은 숫자를 써 봅시다.',
                          questionTextSize: screenWidth * 0.03,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // 여기에 문제 푸는 ui 및 삽입
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CountWidget(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              data: problemData["p1"],
                              left: zoneKeys["p1-1"]!,
                              right: zoneKeys["p1-2"]!,
                            ),
                            CountWidget(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              data: problemData["p2"],
                              left: zoneKeys["p2-1"]!,
                              right: zoneKeys["p2-2"]!,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CountWidget(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              data: problemData["p3"],
                              left: zoneKeys["p3-1"]!,
                              right: zoneKeys["p3-2"]!,
                            ),
                            CountWidget(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              data: problemData["p4"],
                              left: zoneKeys["p4-1"]!,
                              right: zoneKeys["p4-2"]!,
                            ),
                          ],
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
                                  // TODO : 정답 체크 로직 구현 시 해당 부분 지우고 주석 활성화
                                  // onPressed: () => onNextPressed(),
                                  onPressed: () async {
                                    await checkAnswer();
                                  }
                                  // onPressed: () async {
                                  //   if (isSubmitted) return;
                                  //   setState(() {
                                  //     showSubmitPopup = true;
                                  //   });
                                  //   await checkAnswer();
                                  //   await submitActivity(context);
                                  //   submitController.forward();
                                  // },
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
                                    checkAnswer();
                                    setState(() {
                                      showSubmitPopup = true;
                                    });
                                    submitController.forward();
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
