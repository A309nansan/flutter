import 'dart:convert';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/level_1/2_1/widgets/clickable_animal_card.dart';
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
import '../widgets/animal_card.dart';

class LevelOneTwoOneMain1 extends StatefulWidget {
  final String problemCode;
  const LevelOneTwoOneMain1({super.key, required this.problemCode});

  @override
  State<LevelOneTwoOneMain1> createState() => _LevelOneTwoOneMain1State();
}

class _LevelOneTwoOneMain1State extends State<LevelOneTwoOneMain1>
    with TickerProviderStateMixin {
  // 필수 변수
  final ScreenshotController screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  int childId = 0;
  int? elapsedSeconds;
  int current = 1;
  int total = 1;
  String nextProblemCode = '';
  String problemCode = 'enlv1s2c1jy1';
  bool isSubmitted = false;
  bool isCorrect = false;
  bool showSubmitPopup = false;
  bool isLoading = true;
  bool isEnd = true;
  Map<String, dynamic> problemData = {};
  Map<String, dynamic> answerData = {};
  Map<String, dynamic> selectedAnswers = {
    'p1': {'number': 0},
    'p2': {'number': 0},
    'p3': {'number': 0},
    'p4': {'number': 0},
  };
  late AnimationController submitController;
  late Animation<double> submitAnimation;

  // 문제별 변수
  List imageUrl = [];
  Map<String, dynamic> p1Data = {'urls': [], 'text': '', 'candidates': []};
  Map<String, dynamic> p2Data = {'urls': [], 'text': '', 'candidates': []};
  Map<String, dynamic> p3Data = {'urls': [], 'text': '', 'candidates': []};
  Map<String, dynamic> p4Data = {'urls': [], 'text': '', 'candidates': []};
  late final int answer1 = answerData['p1']['number'];
  late final int answer2 = answerData['p2']['number'];
  late final int answer3 = answerData['p3']['number'];
  late final int answer4 = answerData['p4']['number'];

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

      setState(() {
        nextProblemCode = response.nextProblemCode;

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
    imageUrl = problemData['image_url'];
    p1Data = problemData['p1'];
    p2Data = problemData['p2'];
    p3Data = problemData['p3'];
    p4Data = problemData['p4'];
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

  // inputdata 처리 함수
  void _processInputData(int questionNumber, int candidate) {
    setState(() {
      switch (questionNumber) {
        case 1:
          selectedAnswers['p1']['number'] = candidate;
          break;
        case 2:
          selectedAnswers['p2']['number'] = candidate;
          break;
        case 3:
          selectedAnswers['p3']['number'] = candidate;
          break;
        case 4:
          selectedAnswers['p4']['number'] = candidate;
          break;
      }
      debugPrint('$selectedAnswers');
    });
  }

  void checkAnswer() {
    isCorrect = DeepCollectionEquality().equals(answerData, selectedAnswers);
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
                              questionText: '다음 동물카드를 보고 순서에 알맞은 동물을 골라보세요.',
                              questionTextSize: screenWidth * 0.025,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(imageUrl.length, (index) {
                                return Row(
                                  children: [
                                    AnimalCard(
                                      animalName: imageUrl[index], // 이미지 URL 전달
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                  ],
                                );
                              }),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  '1. ${p1Data['text']} 순서에 있는 동물을 찾아 터치 하세요.',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClickableAnimalCard(
                                  animalName: p1Data['urls']?[0] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p1']['number'] ==
                                      p1Data['candidates'][0],
                                  onTap:
                                      () => _processInputData(
                                        1,
                                        p1Data['candidates'][0],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p1Data['urls']?[1] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p1']['number'] ==
                                      p1Data['candidates'][1],
                                  onTap:
                                      () => _processInputData(
                                        1,
                                        p1Data['candidates'][1],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p1Data['urls']?[2] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p1']['number'] ==
                                      p1Data['candidates'][2],
                                  onTap:
                                      () => _processInputData(
                                        1,
                                        p1Data['candidates'][2],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p1Data['urls']?[3] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p1']['number'] ==
                                      p1Data['candidates'][3],
                                  onTap:
                                      () => _processInputData(
                                        1,
                                        p1Data['candidates'][3],
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  '2. ${p2Data['text']} 순서에 있는 동물을 찾아 터치 하세요.',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClickableAnimalCard(
                                  animalName: p2Data['urls']?[0] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p2']['number'] ==
                                      p2Data['candidates'][0],
                                  onTap:
                                      () => _processInputData(
                                        2,
                                        p2Data['candidates'][0],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p2Data['urls']?[1] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p2']['number'] ==
                                      p2Data['candidates'][1],
                                  onTap:
                                      () => _processInputData(
                                        2,
                                        p2Data['candidates'][1],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p2Data['urls']?[2] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p2']['number'] ==
                                      p2Data['candidates'][2],
                                  onTap:
                                      () => _processInputData(
                                        2,
                                        p2Data['candidates'][2],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p2Data['urls']?[3] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p2']['number'] ==
                                      p2Data['candidates'][3],
                                  onTap:
                                      () => _processInputData(
                                        2,
                                        p2Data['candidates'][3],
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  '3. ${p3Data['text']} 순서에 있는 동물을 찾아 터치 하세요.',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClickableAnimalCard(
                                  animalName: p3Data['urls']?[0] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p3']['number'] ==
                                      p3Data['candidates'][0],
                                  onTap:
                                      () => _processInputData(
                                        3,
                                        p3Data['candidates'][0],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p3Data['urls']?[1] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p3']['number'] ==
                                      p3Data['candidates'][1],
                                  onTap:
                                      () => _processInputData(
                                        3,
                                        p3Data['candidates'][1],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p3Data['urls']?[2] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p3']['number'] ==
                                      p3Data['candidates'][2],
                                  onTap:
                                      () => _processInputData(
                                        3,
                                        p3Data['candidates'][2],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p3Data['urls']?[3] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p3']['number'] ==
                                      p3Data['candidates'][3],
                                  onTap:
                                      () => _processInputData(
                                        3,
                                        p3Data['candidates'][3],
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  '4. ${p4Data['text']} 순서에 있는 동물을 찾아 터치 하세요.',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClickableAnimalCard(
                                  animalName: p4Data['urls']?[0] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p4']['number'] ==
                                      p4Data['candidates'][0],
                                  onTap:
                                      () => _processInputData(
                                        4,
                                        p4Data['candidates'][0],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p4Data['urls']?[1] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p4']['number'] ==
                                      p4Data['candidates'][1],
                                  onTap:
                                      () => _processInputData(
                                        4,
                                        p4Data['candidates'][1],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p4Data['urls']?[2] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p4']['number'] ==
                                      p4Data['candidates'][2],
                                  onTap:
                                      () => _processInputData(
                                        4,
                                        p4Data['candidates'][2],
                                      ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                ClickableAnimalCard(
                                  animalName: p4Data['urls']?[3] ?? 'error',
                                  isSelected:
                                      selectedAnswers['p4']['number'] ==
                                      p4Data['candidates'][3],
                                  onTap:
                                      () => _processInputData(
                                        4,
                                        p4Data['candidates'][3],
                                      ),
                                ),
                              ],
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
