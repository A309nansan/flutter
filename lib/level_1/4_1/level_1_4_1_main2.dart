import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/modules/drag_drop2/controllers/draggable2_controller.dart';
import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_drop_zone.dart';
import 'package:nansan_flutter/modules/drag_drop2/models/draggable2_image_card.dart';
import 'package:nansan_flutter/modules/drag_drop2/widgets/draggable2_card.dart';
import 'package:nansan_flutter/modules/drag_drop2/widgets/draggable2_drop_zone_widget.dart';
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

// ✅ 상태변경 1. StatefulWidget -> ConsumerStatefulWidget
class Level141main2 extends ConsumerStatefulWidget {
  final String problemCode;
  const Level141main2({super.key, required this.problemCode});

  @override
  // ✅ 상태변경 2. State -> ConsumerState
  ConsumerState<Level141main2> createState() => Level141main2State();
}

// ✅ 상태변경 3. State -> ConsumerState
class Level141main2State extends ConsumerState<Level141main2>
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
  Map problemData = {};
  Map answerData = {};
  Map<String, dynamic> selectedAnswers = {};
  List<List<String>> fixedImageUrls = [];
  List<Map<String, String>> candidates = [];

  // 문제별 변수
  late AnimationController _menuAnimationController;
  final DragDrop2Controller dd2controller = DragDrop2Controller(
    imageUrl: 'assets/images/number/bg_apple/1.webp',
  );
  late Draggable2DropZone q1Zone;
  late Draggable2DropZone q2Zone;
  late int givenNumber;
  late int problemNumber;
  late int q1Number;
  late int q2Number;
  late int exAnswer;
  late int exNumber;

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

    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  // 페이지를 나갈 때, 실행되는 함수. 수정 필요 x
  @override
  void dispose() {
    _menuAnimationController.dispose();
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
      final saved = await EnProblemService.loadProblemResults(
        problemCode,
        childId,
      );
      ref.read(problemProgressProvider.notifier).setFromStorage(saved);

      // ✅ 저장된 이어풀기 기록 확인용(확인 완료 시 지우기)
      final progress = ref.read(problemProgressProvider);
      debugPrint("📦 불러온 문제 기록: $progress");

      // ✅ 문제 이어풀기 기록 저장
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
      ref.read(problemProgressProvider.notifier).record(problemCode, isCorrect);

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
  void _processProblemData(Map problemData) {
    exNumber = problemData['ex'][0];
    exAnswer = problemData['ex'][1];
    problemNumber = problemData['number'];
    // exNumber = problemData['ex'];
    q1Number = problemData['q1'];
    q2Number = problemData['q2'];
  }

  // 문제 푸는 로직 수행할때, seletedAnswers 데이터 넣는 로직
  Future<void> _processInputData() async {
    // 비동기 작업 수행
    selectedAnswers['a1'] = q1Zone.cards.length;
    selectedAnswers['a2'] = q2Zone.cards.length;
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
      await EnProblemService.saveProblemResults(progress, problemCode, childId);

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

  //드래그 앤 드랍2 관련 로직
  void _resetState(Draggable2DropZone zone) {
    setState(() {
      dd2controller.resetState(zone.id);
    });
  }

  void _onCardRemoved(Draggable2DropZone zone, Draggable2ImageCard card) {
    setState(() {
      dd2controller.removeCardFromZone(zone, card);
    });
  }

  void _onCardAdded(Draggable2DropZone zone) {
    setState(() {
      dd2controller.addCardToZone(zone);
    });
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
        width: screenWidth * 0.3,
        height: screenWidth * 0.15,
      );

      dd2controller.dropZones.add(q1Zone);

      q2Zone = Draggable2DropZone(
        id: 2,
        width: screenWidth * 0.3,
        height: screenWidth * 0.15,
      );

      dd2controller.dropZones.add(q2Zone);
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
                                  Stack(
                                    children: [
                                      Column(
                                        children: [
                                          NewQuestionTextWidget(
                                            questionText:
                                                '2. <보기>와 같이 사과가 $problemNumber개 되도록 오른쪽  사과주머니를 \n클릭하여 열고 빈칸에 알맞게 사과를 옮겨 보세요.',
                                            questionTextSize:
                                                screenWidth * 0.03,
                                          ),
                                          Container(
                                            width: screenWidth * 0.95,
                                            height: screenHeight * 0.2,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.amber,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: screenWidth * 0.07,
                                                  height: screenHeight * 0.02,
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                  ),
                                                  child: Text(
                                                    '<보기>',
                                                    style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.02,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: screenHeight * 0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: screenWidth * 0.3,
                                                      height:
                                                          screenHeight * 0.15,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          width: 2,
                                                          color:
                                                              Colors.lightBlue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Image.asset(
                                                        'assets/images/number/apple/$exNumber.png',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: screenWidth * 0.03,
                                                    ),
                                                    Container(
                                                      width: screenWidth * 0.3,
                                                      height:
                                                          screenHeight * 0.15,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          width: 2,
                                                          color:
                                                              Colors.lightBlue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Image.asset(
                                                        'assets/images/number/apple/$exAnswer.png',
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .arrow_right_alt_rounded,
                                                      size: screenWidth * 0.1,
                                                      color: Colors.lightBlue,
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: screenWidth * 0.15,
                                                      height:
                                                          screenWidth * 0.15,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              Colors.lightBlue,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '$problemNumber',
                                                        style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                              0.07,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: screenHeight * 0.01,
                                        right: screenWidth * 0.03,
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
                                                                  'assets/images/number/bg_apple/1.webp',
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
                                                                    'assets/images/number/bg_apple/1.webp',
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
                                                                'assets/images/number/bg_apple/1.webp',
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
                                  SizedBox(height: screenHeight * 0.01),
                                  SizedBox(
                                    width: screenWidth * 0.95,
                                    height: screenHeight * 0.23,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.015,
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              width: screenWidth * 0.05,
                                              height: screenWidth * 0.05,
                                              decoration: BoxDecoration(
                                                color: Colors.purple[100],
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Text(
                                                '1',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: screenWidth * 0.038,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.015),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: screenWidth * 0.3,
                                              height: screenHeight * 0.15,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 2,
                                                  color: Colors.lightBlue,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Image.asset(
                                                'assets/images/number/apple/$q1Number.png',
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.03),
                                            Container(
                                              width: screenWidth * 0.3,
                                              height: screenHeight * 0.15,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 2,
                                                  color: Colors.lightBlue,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: SizedBox(
                                                width: screenWidth * 0.3,
                                                height: screenWidth * 0.15,
                                                child: Draggable2DropzoneWidget(
                                                  zone: q1Zone,
                                                  controller: dd2controller,
                                                  onReset: _resetState,
                                                  onCardRemoved: _onCardRemoved,
                                                  onCardAdded: _onCardAdded,
                                                  width: screenWidth * 0.3,
                                                  height: screenWidth * 0.15,
                                                  cardSize: screenWidth * 0.05,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_right_alt_rounded,
                                              size: screenWidth * 0.1,
                                              color: Colors.lightBlue,
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              width: screenWidth * 0.15,
                                              height: screenWidth * 0.15,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.lightBlue,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                '$problemNumber',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.07,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.95,
                                    height: screenHeight * 0.23,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.015,
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              width: screenWidth * 0.05,
                                              height: screenWidth * 0.05,
                                              decoration: BoxDecoration(
                                                color: Colors.purple[100],
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Text(
                                                '2',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: screenWidth * 0.038,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.015),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: screenWidth * 0.3,
                                              height: screenHeight * 0.15,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 2,
                                                  color: Colors.lightBlue,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Image.asset(
                                                'assets/images/number/apple/$q2Number.png',
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.03),
                                            Container(
                                              width: screenWidth * 0.3,
                                              height: screenHeight * 0.15,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 2,
                                                  color: Colors.lightBlue,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: SizedBox(
                                                width: screenWidth * 0.3,
                                                height: screenWidth * 0.15,
                                                child: Draggable2DropzoneWidget(
                                                  zone: q2Zone,
                                                  controller: dd2controller,
                                                  onReset: _resetState,
                                                  onCardRemoved: _onCardRemoved,
                                                  onCardAdded: _onCardAdded,
                                                  width: screenWidth * 0.3,
                                                  height: screenWidth * 0.15,
                                                  cardSize: screenWidth * 0.05,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_right_alt_rounded,
                                              size: screenWidth * 0.1,
                                              color: Colors.lightBlue,
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              width: screenWidth * 0.15,
                                              height: screenWidth * 0.15,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.lightBlue,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                '$problemNumber',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.07,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
