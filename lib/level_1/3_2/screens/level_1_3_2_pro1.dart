import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/level_1/3_2/widgets/box_with_line_widget.dart';
import 'package:nansan_flutter/modules/drag_drop2/controllers/draggable2_controller.dart';
import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_drop_zone.dart';
import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_image_card.dart';
import 'package:nansan_flutter/modules/drag_drop2/widgets/draggable2_card.dart';
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

import '../../../shared/provider/en_riverpod_provider.dart';
import '../../../shared/widgets/en_result_popup.dart';

//TODO : 이미지 수정
class LevelOneThreeTwoPro1 extends ConsumerStatefulWidget {
  final String problemCode;
  const LevelOneThreeTwoPro1({super.key, required this.problemCode});

  @override
  ConsumerState<LevelOneThreeTwoPro1> createState() =>
      LevelOneThreeTwoPro1State();
}

class LevelOneThreeTwoPro1State extends ConsumerState<LevelOneThreeTwoPro1>
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

  List q1Data = [];
  List q2Data = [];
  int? selectedQ1;
  int? selectedQ2;

  // 문제별 변수
  late AnimationController _menuAnimationController;
  final DragDrop2Controller dd2controller = DragDrop2Controller(
    imageUrl: 'assets/images/number/dot/1.png',
  );
  late Draggable2DropZone q1Zone;
  late Draggable2DropZone q2Zone;
  late Draggable2DropZone q3Zone;
  late Draggable2DropZone q4Zone;

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

    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

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

      final saved = await EnProblemService.loadProblemResults(
        problemCode,
        childId,
      );
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

      ref.read(problemProgressProvider.notifier).record(problemCode, isCorrect);

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
  void _processProblemData(Map problemData) {
    q1Data = problemData["p1"];
    q2Data = problemData["p2"];
  }

  // 문제 푸는 로직 수행할때, seletedAnswers 데이터 넣는 로직
  void _processInputData({required String questionKey, required int value}) {
    setState(() {
      selectedAnswers[questionKey] = value;
    });
  }

  Future<void> _processInputData2() async {
    List<int> correctAnswer = [
      problemData["p1"][0],
      problemData["p1"][1],
      problemData["p2"][0],
      problemData["p2"][1],];

    List<int> seleAnswer = [
      q1Zone.cards.length,
      q2Zone.cards.length,
      q3Zone.cards.length,
      q4Zone.cards.length,];

    isCorrect = const DeepCollectionEquality().equals(
      correctAnswer,
      seleAnswer,
    );

  }

  // 정답 여부 체크(보통은 이거쓰면됨)
  Future<void> checkAnswer() async {

    await _processInputData2();

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

  // 다음페이지로 가는 함수. 수정 필요 x
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

    // 드롭존 초기화 또는 업데이트
    if (dd2controller.dropZones.isEmpty) {
      q1Zone = Draggable2DropZone(
        id: 1,
        width: screenWidth * 0.35,
        height: screenWidth * 0.15,
      );
      q2Zone = Draggable2DropZone(
        id: 2,
        width: screenWidth * 0.35,
        height: screenWidth * 0.15,
      );
      q3Zone = Draggable2DropZone(
        id: 3,
        width: screenWidth * 0.35,
        height: screenWidth * 0.15,
      );
      q4Zone = Draggable2DropZone(
        id: 4,
        width: screenWidth * 0.35,
        height: screenWidth * 0.15,
      );

      dd2controller.dropZones.add(q1Zone);
      dd2controller.dropZones.add(q2Zone);
      dd2controller.dropZones.add(q3Zone);
      dd2controller.dropZones.add(q4Zone);
    }

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
                      child: Stack(
                        children: [
                          Column(
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
                                          '숫자를 읽고, 주머니에서 ??를 꺼내 회색 빈칸에 넣어보세요.',
                                      questionTextSize: screenWidth * 0.03,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('       그리고 나서, 수직선에서 더 작은 숫자를 클릭하세요.',
                                          style: TextStyle(fontSize: screenWidth * 0.03,
                                              fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.06),
                                    // 여기에 문제 푸는 ui 및 삽입
                                    BoxWithLineWidget(
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                      leftZone: q1Zone,
                                      rightZone: q2Zone,
                                      controller: dd2controller,
                                      data: q1Data,
                                      onSelected: (value) {
                                        _processInputData(
                                          questionKey: "a1",
                                          value: value,
                                        );
                                      },
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    BoxWithLineWidget(
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                      leftZone: q3Zone,
                                      rightZone: q4Zone,
                                      controller: dd2controller,
                                      data: q2Data,
                                      onSelected: (value) {
                                        _processInputData(
                                          questionKey: "a2",
                                          value: value,
                                        );
                                      },
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
                          Positioned(
                            top: screenHeight * 0.06,
                            right: screenWidth * 0.04,
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return MenuAnchor(
                                  onOpen: () {
                                    // 메뉴가 열릴 때 애니메이션 시작
                                    _menuAnimationController
                                        .forward();
                                  },
                                  onClose: () {
                                    // 메뉴가 닫힐 때 애니메이션 리셋
                                    _menuAnimationController
                                        .reset();
                                  },
                                  builder: (
                                      context,
                                      controller,
                                      child,
                                      ) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (controller.isOpen) {
                                          controller.close();
                                        } else {
                                          controller.open();
                                        }
                                      },
                                      child: Container(
                                        width: screenWidth * 0.1,
                                        height: screenWidth * 0.1,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.purple[100],
                                          borderRadius:
                                          BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black54,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Image.asset(
                                          'assets/images/number/pouch/apple_pouch.webp',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                  menuChildren: [
                                    FadeTransition(
                                      opacity:
                                      _menuAnimationController,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(
                                            0.0,
                                            -0.5,
                                          ),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent:
                                            _menuAnimationController,
                                            curve: Curves.easeOut,
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.all(
                                            4.0,
                                          ),
                                          child: SizedBox(
                                            width:
                                            screenWidth * 0.1,
                                            height:
                                            screenWidth * 0.1,
                                            child: Draggable(
                                              data:
                                              dd2controller
                                                  .sourceCard,
                                              feedback: Material(
                                                elevation: 4.0,
                                                color:
                                                Colors
                                                    .transparent,
                                                child: Draggable2Card(
                                                  imageUrl:
                                                  'assets/images/number/dot/1.png',
                                                  cardWidth:
                                                  screenWidth *
                                                      0.1,
                                                  cardHeight:
                                                  screenWidth *
                                                      0.1,
                                                  opacity: 0.7,
                                                ),
                                              ),
                                              childWhenDragging:
                                              Draggable2Card(
                                                imageUrl:
                                                'assets/images/number/dot/1.png',
                                                cardWidth:
                                                screenWidth *
                                                    0.1,
                                                cardHeight:
                                                screenWidth *
                                                    0.1,
                                                opacity: 0.5,
                                              ),
                                              child: Draggable2Card(
                                                imageUrl:
                                                'assets/images/number/dot/1.png',
                                                cardWidth:
                                                screenWidth *
                                                    0.1,
                                                cardHeight:
                                                screenWidth *
                                                    0.1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
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
