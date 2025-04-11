import 'dart:convert';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/drag_drop/controllers/drag_drop_controller.dart';
import 'package:nansan_flutter/modules/drag_drop/widgets/draggable_card_list.dart';
import 'package:nansan_flutter/modules/drag_drop/widgets/empty_zone.dart';
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
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class LevelOneTwoOneThink extends StatefulWidget {
  final String problemCode;
  final DragDropController controller;

  const LevelOneTwoOneThink({
    super.key,
    required this.problemCode,
    required this.controller,
  });

  @override
  State<LevelOneTwoOneThink> createState() => _LevelOneTwoOneThinkState();
}

class _LevelOneTwoOneThinkState extends State<LevelOneTwoOneThink>
    with TickerProviderStateMixin {
  // 필수코드
  final ScreenshotController screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  int childId = 0;
  int? elapsedSeconds;
  int current = 1;
  int total = 1;
  String nextProblemCode = 'enlv1s2c1jy1';
  String problemCode = 'enlv1s2c1gn1';
  bool isSubmitted = false;
  bool isCorrect = false;
  bool showSubmitPopup = false;
  bool isLoading = true;
  bool isEnd = false;
  Map problemData = {};
  Map answerData = {};
  // selectedAnswers는 문제유형에 따라 변경 필요
  Map<String, dynamic> selectedAnswers = {};
  late AnimationController submitController;
  late Animation<double> submitAnimation;

  //문제별 변수
  String imageUrl1 = '';
  String imageUrl2 = '';
  String imageUrl3 = '';
  String name1 = '';
  String name2 = '';
  String name3 = '';
  List<Map<String, String>> candidates = [];

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

  void _processProblemData(Map problemData) {
    candidates.clear();

    if (problemData.containsKey('person1')) {
      imageUrl1 = problemData['person1']['image'] ?? '';
      name1 = problemData['person1']['name'] ?? '';

      candidates.add({'image_name': name1, 'image_url': ''});
    }

    if (problemData.containsKey('person2')) {
      imageUrl2 = problemData['person2']['image'] ?? '';
      name2 = problemData['person2']['name'] ?? '';

      candidates.add({'image_name': name2, 'image_url': ''});
    }

    if (problemData.containsKey('person3')) {
      imageUrl3 = problemData['person3']['image'] ?? '';
      name3 = problemData['person3']['name'] ?? '';

      candidates.add({'image_name': name3, 'image_url': ''});
    }
  }

  void _processInputData() {
    final controller = Provider.of<DragDropController>(context, listen: false);

    selectedAnswers = {"problem1": "", "problem2": "", "problem3": ""};

    for (int zoneKey = 1; zoneKey <= 3; zoneKey++) {
      final card = controller.zoneCards[zoneKey];
      if (card != null) {
        switch (zoneKey) {
          case 1:
            selectedAnswers["problem1"] = card.imageName;
            break;
          case 2:
            selectedAnswers["problem2"] = card.imageName;
            break;
          case 3:
            selectedAnswers["problem3"] = card.imageName;
            break;
        }
      }
    }

    debugPrint('$selectedAnswers');
  }

  void checkAnswer() {
    _processInputData();
    isCorrect = DeepCollectionEquality().equals(answerData, selectedAnswers);
    submitAnswer();
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
                              headerText: '개념학습활동',
                              headerTextSize: screenWidth * 0.028,
                              subTextSize: screenWidth * 0.018,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            NewQuestionTextWidget(
                              questionText:
                                  '친구들이 키를 재고 있어요. 친구들의 키가 작은 순서대로 빈칸에 넣어 봅시다.',
                              questionTextSize: screenWidth * 0.025,
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: screenWidth * 0.9,
                              height: screenHeight * 0.38,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.lightBlue,
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/schoolBackground.jpg',
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.2,
                                        child: Image.network(
                                          imageUrl1,
                                          errorBuilder:
                                              (_, __, ___) => Icon(Icons.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.3,
                                        child: Image.network(
                                          imageUrl2,
                                          errorBuilder:
                                              (_, __, ___) => Icon(Icons.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.35,
                                        child: Image.network(
                                          imageUrl3,
                                          errorBuilder:
                                              (_, __, ___) => Icon(Icons.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            // Question 1
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '1. 첫 번째로 키가 작은 친구는 누구인가요? ',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                EmptyZone(
                                  zoneKey: 1,
                                  width: screenWidth * 0.15,
                                  height: screenHeight * 0.055,
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  '가 첫 번째로 작아요!',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            // Question 2
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '2. 두 번째로 키가 작은 친구는 누구인가요? ',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                EmptyZone(
                                  zoneKey: 2,
                                  width: screenWidth * 0.15,
                                  height: screenHeight * 0.055,
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  '가 두 번째로 작아요!',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            // Question 3
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '3. 세 번째로 키가 작은 친구는 누구인가요? ',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                EmptyZone(
                                  zoneKey: 3,
                                  width: screenWidth * 0.15,
                                  height: screenHeight * 0.055,
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  '가 세 번째로 작아요!',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            DraggableCardList(
                              showRemoveButton: false,
                              candidates: candidates,
                              boxWidth: 400,
                              boxHeight: 80,
                              cardWidth: 80,
                              cardHeight: 50,
                              controller: widget.controller,
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
