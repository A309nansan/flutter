import 'dart:convert';
import 'package:flutter/foundation.dart';
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
import 'package:screenshot/screenshot.dart';
import 'package:collection/collection.dart';

class LevelOneOneTwoThink extends StatefulWidget {
  final String problemCode;
  final DragDropController controller;
  const LevelOneOneTwoThink({
    super.key,
    required this.problemCode,
    required this.controller,
  });

  @override
  State<LevelOneOneTwoThink> createState() => LevelOneOneTwoThinkState();
}

class LevelOneOneTwoThinkState extends State<LevelOneOneTwoThink>
    with TickerProviderStateMixin {
  final ScreenshotController screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  int childId = 0;
  int? elapsedSeconds;
  int current = 1;
  int total = 1;
  String nextProblemCode = 'enlv1s1c2jy1';
  String problemCode = 'enlv1s1c2gn1';
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
  late AnimationController submitController;
  late Animation<double> submitAnimation;

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
    _timerController.dispose();
    isSubmitted = false;
    super.dispose();
  }

  Future<void> _loadQuestionData() async {
    try {
      final response = await _apiService.loadProblemData(problemCode);
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

  Future<void> _submitAnswer() async {
    _timerController.stop();

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

  void _processProblemData(Map problemData) {
    final Map<String, dynamic> fixedCardUrl = problemData['fixed'];
    final fixedcategories = {'dot', 'numeric1', 'hangeul1'};
    String? dynamicCategory;

    for (var key in fixedCardUrl.keys) {
      if (!fixedcategories.contains(key)) {
        dynamicCategory = key;
        break;
      }
    }

    fixedImageUrls = [
      if (dynamicCategory != null)
        (fixedCardUrl[dynamicCategory] as List<dynamic>).cast<String>(),
      (fixedCardUrl['dot'] ?? []).cast<String>(),
      (fixedCardUrl['numeric1'] ?? []).cast<String>(),
      (fixedCardUrl['hangeul1'] ?? []).cast<String>(),
    ];

    final List<dynamic> candidateList = problemData['candidates'];
    setState(() {
      candidates =
          candidateList
              .map(
                (c) => {
                  'image_name': c['image_name'].toString(),
                  'image_url': c['image_url'].toString(),
                },
              )
              .toList();
    });
  }

  void _processInputData() {
    final Map<String, dynamic> cardUrl = problemData['fixed'];
    final categories = {'dot', 'numeric1', 'hangeul1'};
    String? dynamicCategory;

    for (var key in cardUrl.keys) {
      if (!categories.contains(key)) {
        dynamicCategory = key;
        break;
      }
    }

    final gridData = List.generate(
      4,
      (_) => List<Map<String, dynamic>?>.filled(3, null),
    );

    widget.controller.zoneCards.forEach((zoneKey, cardData) {
      if (cardData != null) {
        final row = (zoneKey - 1) ~/ 3; // 0-based row index (0~3)
        final col = (zoneKey - 1) % 3; // 0-based column index (0~2)
        gridData[row][col] = {'image_name': cardData.imageName};
      }
    });

    // 최종 데이터 구조 변환
    setState(() {
      selectedAnswers['$dynamicCategory'] = gridData[0];
      selectedAnswers['dot'] = gridData[1];
      selectedAnswers['hangeul1'] = gridData[3];
      selectedAnswers['numeric1'] = gridData[2];
    });
  }

  void checkAnswer() {
    isCorrect = DeepCollectionEquality().equals(answerData, selectedAnswers);
    _submitAnswer();
  }

  Widget _buildHeaderItem() => SizedBox(
    width: 100,
    height: 30,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: const [
        Text('1 큰 수', style: TextStyle()),
        Icon(Icons.arrow_right_alt_outlined),
      ],
    ),
  );

  Widget _buildContainer(String imageUrl) => Container(
    width: 95,
    height: 95,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: FractionallySizedBox(
      widthFactor: 0.90,
      heightFactor: 0.90,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) => const Center(child: Text('이미지 오류')),
      ),
    ),
  );

  Widget _buildRow(List<Widget> children) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: children);

  Widget _buildHeaderRow() => _buildRow(
    List.generate(
        5,
        (i) => _buildHeaderItem(),
      ).expand((w) => [w, const SizedBox(width: 15)]).toList()
      ..removeLast(),
  );

  Widget _buildContentRow(int startZoneKey) {
    final rowIndex = (startZoneKey - 1) ~/ 3;
    final currentImages =
        rowIndex < fixedImageUrls.length ? fixedImageUrls[rowIndex] : [];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentImages.isNotEmpty) ...[
          _buildContainer(currentImages[0]),
          const SizedBox(width: 15),
          if (currentImages.length > 1) _buildContainer(currentImages[1]),
          const SizedBox(width: 15),
        ],
        ...List.generate(
            3,
            (i) => EmptyZone(
              zoneKey: startZoneKey + i,
              width: 100,
              height: 100,
              onDrop: _processInputData,
            ),
          ).expand((w) => [w, const SizedBox(width: 15)]).toList()
          ..removeLast(),
      ],
    );
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
                              questionText: '회색 빈칸에 알맞은 1 큰 수를 나타내는 그림은 무엇일까요?',
                              questionTextSize: screenWidth * 0.03,
                            ),
                            _buildHeaderRow(),
                            ...List.generate(
                              4,
                              (i) => Column(
                                children: [
                                  _buildContentRow(1 + i * 3),
                                  if (i < 3)
                                    SizedBox(height: screenHeight * 0.01),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            NewQuestionTextWidget(
                              questionText: '아래의 카드들을 알맞은 위치에 넣어보세요!',
                              questionTextSize: screenWidth * 0.03,
                            ),
                            DraggableCardList(
                              showRemoveButton: true,
                              candidates: candidates,
                              boxWidth: 600,
                              boxHeight: 220,
                              cardWidth: 95,
                              cardHeight: 95,
                              controller: widget.controller,
                            ),
                            SizedBox(height: screenHeight * 0.02),
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
