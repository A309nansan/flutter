import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
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

class LevelOneOneOneThink extends StatefulWidget {
  final String problemCode;
  const LevelOneOneOneThink({super.key, required this.problemCode});

  @override
  State<LevelOneOneOneThink> createState() => LevelOneOneOneThinkState();
}

class LevelOneOneOneThinkState extends State<LevelOneOneOneThink>
    with TickerProviderStateMixin {
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

  Map<String, dynamic> problemData = {};
  Map<String, dynamic> answerData = {};
  Map<String, dynamic> selectedAnswers = {};

  List<List<String>> fixedImageUrls = [];
  List<List<String>> candidates = [];

  @override
  void initState() {
    super.initState();
    init();
    submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    submitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: submitController, curve: Curves.elasticOut),
    );

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
        problemData = response.problem;
        answerData = response.answer;
        current = response.current;
        total = response.total;
      });

      _processProblemData(problemData);

      // 절대 위치 계산 로직 제거
    } catch (e) {
      debugPrint('Error loading question data: $e');
    }
  }

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

  void init() async {
    childId = (await SecureStorageService.getChildId())!;
    EnProblemService.saveContinueProblem(widget.problemCode, childId);
  }

  // 문제 데이터 처리 - 상대 좌표만 사용
  void _processProblemData(Map<String, dynamic> problemData) {}

  void checkAnswer() {
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
                                  questionText: '같은 수를 의미하는 것끼리 선을 그어 이어 봅시다.',
                                  questionTextSize: screenWidth * 0.03,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: List.generate(9 * 2 - 1, (
                                        index,
                                      ) {
                                        if (index.isEven) {
                                          int number =
                                              (index ~/ 2) + 1; // 1부터 9까지
                                          return Container(
                                            width: screenWidth * 0.15,
                                            height: screenHeight * 0.067,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.lightBlue,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.asset(
                                              'assets/images/number/dot/$number.png',
                                            ),
                                          );
                                        } else {
                                          // 간격 조정용 SizedBox
                                          return SizedBox(
                                            height: screenHeight * 0.0125,
                                          ); // 원하는 간격으로 조정
                                        }
                                      }),
                                    ),
                                    Column(
                                      children: List.generate(9 * 2 - 1, (
                                        index,
                                      ) {
                                        if (index.isEven) {
                                          int number =
                                              (index ~/ 2) + 1; // 1부터 9까지
                                          return Container(
                                            width: screenWidth * 0.15,
                                            height: screenHeight * 0.067,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.lightBlue,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.asset(
                                              'assets/images/number/numeric1/$number.png',
                                            ),
                                          );
                                        } else {
                                          // 간격 조정용 SizedBox
                                          return SizedBox(
                                            height: screenHeight * 0.0125,
                                          ); // 원하는 간격으로 조정
                                        }
                                      }),
                                    ),
                                    Column(
                                      children: List.generate(9 * 2 - 1, (
                                        index,
                                      ) {
                                        if (index.isEven) {
                                          int number =
                                              (index ~/ 2) + 1; // 1부터 9까지
                                          return Container(
                                            width: screenWidth * 0.15,
                                            height: screenHeight * 0.067,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.lightBlue,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.asset(
                                              'assets/images/number/hangeul1/$number.png',
                                            ),
                                          );
                                        } else {
                                          // 간격 조정용 SizedBox
                                          return SizedBox(
                                            height: screenHeight * 0.0125,
                                          ); // 원하는 간격으로 조정
                                        }
                                      }),
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
                                    key: ValueKey('${isSubmitted}_$isCorrect'),
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
