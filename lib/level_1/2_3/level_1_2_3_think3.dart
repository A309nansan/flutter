import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/level_1/2_3/widgets/line_painter.dart';
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

class LevelOneTwoThreeThink3 extends StatefulWidget {
  final String problemCode;
  const LevelOneTwoThreeThink3({super.key, required this.problemCode});

  @override
  State<LevelOneTwoThreeThink3> createState() => _LevelOneTwoThreeThink3State();
}

class _LevelOneTwoThreeThink3State extends State<LevelOneTwoThreeThink3>
    with TickerProviderStateMixin {
  final ScreenshotController screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  late AnimationController submitController;
  late Animation<double> submitAnimation;
  late int childId = 1;
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

  //페이지별 변수
  List<int> numberList = [];
  int givenNumber = 0;
  String? selectedButton = "";
  int? selectedIndex;

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
      setState(() => isSubmitted = true);
    } catch (e) {
      debugPrint('Submit error: $e');
    }
  }

  // 문제 데이터 받아온 후, 문제에 맞게 데이터 조작
  void _processProblemData(Map problemData) {
    numberList =
        (problemData['list'] as List<dynamic>).map((e) => e as int).toList();
    givenNumber = problemData['number'] as int;

    debugPrint('$numberList');
    debugPrint('$givenNumber');
  }

  // 문제 푸는 로직 수행할때, seletedAnswers 데이터 넣는 로직
  Future<void> _processInputData() async {
    selectedAnswers = {"left": false, "right": false};

    if (selectedButton == 'left') {
      selectedAnswers["left"] = true;
    } else if (selectedButton == 'right') {
      selectedAnswers["right"] = true;
    }

    debugPrint('$selectedAnswers');
  }

  // 정답 여부 체크(보통은 이거쓰면됨)
  Future<void> checkAnswer() async {
    await _processInputData();

    isCorrect = const DeepCollectionEquality().equals(
      answerData,
      selectedAnswers,
    );
    debugPrint('$isCorrect');

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

  // 다음페이지로 가는 함수. 수정 필요 x
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
                                  headerText: '개념학습활동',
                                  headerTextSize: screenWidth * 0.028,
                                  subTextSize: screenWidth * 0.018,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                NewQuestionTextWidget(
                                  questionText:
                                      '숫자가 들어갈 알맞은 위치를 찾아 <보기>와 같이 O표 하세요.',
                                  questionTextSize: screenWidth * 0.03,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: screenHeight * 0.3,
                                        width: screenWidth * 0.85,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.orangeAccent,
                                            width: 4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.75,
                                              height: screenHeight * 0.06,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: List.generate(5, (
                                                  index,
                                                ) {
                                                  final contents = [
                                                    '1',
                                                    '',
                                                    '3',
                                                    '○',
                                                    '5',
                                                  ]; //데이터 넣기

                                                  return Container(
                                                    height: screenHeight * 0.06,
                                                    width: screenWidth * 0.15,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFFef1c4),
                                                      border: Border.all(
                                                        color: Color(
                                                          0xFF9c6a17,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child:
                                                          contents[index] == '○'
                                                              ? Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                  border: Border.all(
                                                                    color:
                                                                        Colors
                                                                            .black,
                                                                    width: 2,
                                                                  ),
                                                                ),
                                                              )
                                                              : Text(
                                                                contents[index],
                                                                style: TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth * 0.75,
                                              height: screenHeight * 0.1,
                                              child: Stack(
                                                children: [
                                                  CustomPaint(
                                                    size: Size(
                                                      screenWidth * 0.75,
                                                      screenHeight * 0.1,
                                                    ),
                                                    painter: LinePainter(
                                                      start: Offset(
                                                        screenWidth *
                                                            0.75 *
                                                            0.3,
                                                        0,
                                                      ),
                                                      end: Offset(
                                                        screenWidth *
                                                            0.75 *
                                                            0.5,
                                                        screenHeight * 0.1,
                                                      ),
                                                    ),
                                                  ),
                                                  CustomPaint(
                                                    size: Size(
                                                      screenWidth * 0.75,
                                                      screenHeight * 0.1,
                                                    ),
                                                    painter: LinePainter(
                                                      start: Offset(
                                                        screenWidth *
                                                            0.75 *
                                                            0.5,
                                                        screenHeight * 0.1,
                                                      ),
                                                      end: Offset(
                                                        screenWidth *
                                                            0.75 *
                                                            0.7,
                                                        0,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              child: Container(
                                                height: screenHeight * 0.06,
                                                width: screenWidth * 0.15,
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFef1c4),
                                                  border: Border.all(
                                                    color: Color(0xFF9c6a17),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '4',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orangeAccent,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            "<보기>",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.05),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: screenWidth * 0.75,
                                      height: screenHeight * 0.07,
                                      child: GridView.count(
                                        crossAxisCount: 5,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        childAspectRatio: 1.5,
                                        children: List.generate(5, (index) {
                                          final contents2 = [
                                            numberList[0],
                                            'left',
                                            numberList[1],
                                            'right',
                                            numberList[2],
                                          ];
                                          final isSelectable =
                                              contents2[index] == 'left' ||
                                              contents2[index] == 'right';
                                          final isSelected =
                                              selectedIndex == index;

                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                width: screenWidth * 0.15,
                                                height: screenHeight * 0.1,
                                                child: ElevatedButton(
                                                  onPressed:
                                                      isSelectable
                                                          ? () {
                                                            setState(() {
                                                              if (contents2[index] ==
                                                                  'left') {
                                                                selectedButton =
                                                                    'left';
                                                              } else if (contents2[index] ==
                                                                  'right') {
                                                                selectedButton =
                                                                    'right';
                                                              }
                                                              selectedIndex =
                                                                  index;
                                                            });
                                                          }
                                                          : null,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFFef1c4),
                                                    foregroundColor:
                                                        Colors.black,
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.zero,
                                                          side:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xFF9c6a17,
                                                                ),
                                                              ),
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          5.0,
                                                        ),
                                                    disabledBackgroundColor:
                                                        const Color(0xFFFef1c4),
                                                    disabledForegroundColor:
                                                        Colors.black,
                                                  ),
                                                  child:
                                                      contents2[index] !=
                                                                  'left' &&
                                                              contents2[index] !=
                                                                  'right'
                                                          ? Text(
                                                            '${contents2[index]}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          )
                                                          : const SizedBox.shrink(),
                                                ),
                                              ),

                                              if (isSelected)
                                                Positioned(
                                                  child: IgnorePointer(
                                                    child: Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.black,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),

                                    SizedBox(
                                      width: screenWidth * 0.75,
                                      height: screenHeight * 0.1,
                                      child: Stack(
                                        children: [
                                          CustomPaint(
                                            size: Size(
                                              screenWidth * 0.75,
                                              screenHeight * 0.1,
                                            ),
                                            painter: LinePainter(
                                              start: Offset(
                                                screenWidth * 0.75 * 0.3,
                                                0,
                                              ),
                                              end: Offset(
                                                screenWidth * 0.75 * 0.5,
                                                screenHeight * 0.1,
                                              ),
                                            ),
                                          ),
                                          CustomPaint(
                                            size: Size(
                                              screenWidth * 0.75,
                                              screenHeight * 0.1,
                                            ),
                                            painter: LinePainter(
                                              start: Offset(
                                                screenWidth * 0.75 * 0.5,
                                                screenHeight * 0.1,
                                              ),
                                              end: Offset(
                                                screenWidth * 0.75 * 0.7,
                                                0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      child: Container(
                                        height: screenHeight * 0.06,
                                        width: screenWidth * 0.15,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFef1c4),
                                          border: Border.all(
                                            color: Color(0xFF9c6a17),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$givenNumber',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
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
                                          onPressed: () async {
                                            if (isSubmitted) return;
                                            await checkAnswer();
                                            await submitActivity(context);
                                            setState(() {
                                              showSubmitPopup = true;
                                            });

                                            submitController.forward();
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
