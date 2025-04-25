import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/modules/draw_line/controllers/draw_line_controller.dart';
import 'package:nansan_flutter/modules/draw_line/models/draw_line_models.dart';
import 'package:nansan_flutter/modules/draw_line/widgets/draw_line_dot_widget.dart';
import 'package:nansan_flutter/modules/draw_line/widgets/draw_lines_painter.dart';
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

  // 도트 관련 변수
  // GlobalKey 유지 (위젯 참조용)
  final List<GlobalKey> dotAKeys = List.generate(9, (_) => GlobalKey());
  final List<GlobalKey> dotBKeys = List.generate(9, (_) => GlobalKey());
  final List<GlobalKey> dotCKeys = List.generate(9, (_) => GlobalKey());
  final List<GlobalKey> dotDKeys = List.generate(9, (_) => GlobalKey());

  // offset 리스트 제거
  Offset? _currentDragPosition;

  // DrawLineDots 및 Controller
  late DrawLineDotsController drawLineDotsController;
  List<DrawLineDot> drawLineDots = [];
  List<DrawLineConnection> drawLineConnections = [];

  // 도트 선택 상태
  DrawLineDot? selectedDot;

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

    drawLineDotsController = DrawLineDotsController();

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

  // 문제 데이터 처리 - 상대 좌표만 사용
  void _processProblemData(Map<String, dynamic> problemData) {
    drawLineDots.clear();
    drawLineConnections.clear();
    drawLineDotsController.clearAll();

    // dotA 생성 - 상대 좌표 사용
    if (problemData['dotA'] != null) {
      for (var i = 0; i < problemData['dotA'].length; i++) {
        final item = problemData['dotA'][i];
        drawLineDots.add(
          DrawLineDot(
            id: 'A$i',
            key: 'A',
            position: Offset(item['x'] ?? 0.1, item['y'] ?? (i * 0.1 + 0.1)),
          ),
        );
      }
    }

    // dotB 생성 - 상대 좌표 사용
    if (problemData['dotB'] != null) {
      for (var i = 0; i < problemData['dotB'].length; i++) {
        final item = problemData['dotB'][i];
        drawLineDots.add(
          DrawLineDot(
            id: 'B$i',
            key: 'B',
            position: Offset(item['x'] ?? 0.5, item['y'] ?? (i * 0.1 + 0.1)),
          ),
        );
      }
    }

    // dotC 생성 - 상대 좌표 사용
    if (problemData['dotC'] != null) {
      for (var i = 0; i < problemData['dotC'].length; i++) {
        final item = problemData['dotC'][i];
        drawLineDots.add(
          DrawLineDot(
            id: 'C$i',
            key: 'C',
            position: Offset(item['x'] ?? 0.7, item['y'] ?? (i * 0.1 + 0.1)),
          ),
        );
      }
    }

    // dotD 생성 - 상대 좌표 사용
    if (problemData['dotD'] != null) {
      for (var i = 0; i < problemData['dotD'].length; i++) {
        final item = problemData['dotD'][i];
        drawLineDots.add(
          DrawLineDot(
            id: 'D$i',
            key: 'D',
            position: Offset(item['x'] ?? 0.9, item['y'] ?? (i * 0.1 + 0.1)),
          ),
        );
      }
    }

    // DrawLineDotsController에 도트 추가
    for (final dot in drawLineDots) {
      drawLineDotsController.addDot(dot);
    }
  }

  // 절대 위치 계산하는 _initDrawLineDots() 메서드 제거

  // 연결 규칙 유지
  bool _canConnect(DrawLineDot from, DrawLineDot to) {
    if ((from.key == 'A' && to.key == 'B') ||
        (from.key == 'B' && to.key == 'A')) {
      return true;
    }

    if ((from.key == 'C' && to.key == 'D') ||
        (from.key == 'D' && to.key == 'C')) {
      return true;
    }

    return false;
  }

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

  List<Widget> _buildContainers(
    double screenWidth,
    double screenHeight,
    double sizedHeight,
    int count,
  ) {
    return List.generate(count, (index) {
      return Column(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue),
            ),
          ),
          if (index != count - 1) SizedBox(height: sizedHeight),
        ],
      );
    });
  }

  List<Widget> _buildDotContainers(
    double screenWidth,
    double screenHeight,
    double sizedHeight,
    List<GlobalKey> keys,
    int count,
    String dotKey,
    int offsetBase,
  ) {
    return List.generate(count, (index) {
      final dotId = '$dotKey$index';
      final dot = drawLineDots.firstWhere(
        (d) => d.id == dotId,
        orElse:
            () => DrawLineDot(id: dotId, key: dotKey, position: Offset.zero),
      );

      return Column(
        children: [
          Container(
            key: keys[index], // GlobalKey 유지 (위젯 참조용)
            alignment: Alignment.center,
            width: screenWidth,
            height: screenHeight,
            child: DrawLineDotWidget(
              dot: dot,
              parentSize: Size(screenWidth, screenHeight),
              isSelected: selectedDot?.id == dot.id,
              isHovered: false,
              isConnected: drawLineDotsController.isDotConnected(dot),
              onPointerDown: _onDotPointerDown,
            ),
          ),
          if (index != count - 1) SizedBox(height: sizedHeight),
        ],
      );
    });
  }

  // getDotOffsets() 메서드 제거

  void _onPointerMove(PointerMoveEvent event) {
    if (selectedDot != null) {
      setState(() {
        _currentDragPosition = event.position; // 실시간 좌표 업데이트
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _currentDragPosition = null;
    });
  }

  void _onDotPointerDown(PointerDownEvent event, DrawLineDot dot) {
    setState(() {
      if (selectedDot == null) {
        selectedDot = dot;
      } else if (selectedDot != null && selectedDot != dot) {
        if (_canConnect(selectedDot!, dot)) {
          // 이미 연결되어 있는지 확인
          if (!drawLineDotsController.isDotConnected(selectedDot!) &&
              !drawLineDotsController.isDotConnected(dot)) {
            final connection = DrawLineConnection(
              dot1: selectedDot!,
              dot2: dot,
            );

            drawLineDotsController.addConnection(connection);
            drawLineConnections = List.from(drawLineDotsController.connections);

            // 정답 제출용 데이터에 반영
            selectedAnswers[selectedDot!.id] = dot.id;
          }
        }

        selectedDot = null;
      }
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
                                SizedBox(height: screenHeight * 0.02),
                                // 문제 푸는 UI
                                Listener(
                                  onPointerMove: _onPointerMove,
                                  onPointerUp: _onPointerUp,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          size: Size(
                                            screenWidth,
                                            screenHeight * 0.6,
                                          ),
                                          painter: DrawLinesPainter(
                                            connections: drawLineConnections,
                                            startDot: selectedDot,
                                            currentPosition:
                                                _currentDragPosition,
                                            isDrawingTemporaryLine:
                                                selectedDot != null &&
                                                _currentDragPosition != null,
                                            // dotAbsoluteOffsets 파라미터 제거
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(width: screenWidth * 0.02),
                                          Column(
                                            children: _buildContainers(
                                              screenHeight * 0.1,
                                              screenHeight * 0.068,
                                              screenHeight * 0.01,
                                              9,
                                            ),
                                          ),
                                          Column(
                                            children: _buildDotContainers(
                                              screenHeight * 0.04,
                                              screenHeight * 0.068,
                                              screenHeight * 0.01,
                                              dotAKeys,
                                              9,
                                              'A',
                                              0,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.1),
                                          Column(
                                            children: _buildDotContainers(
                                              screenHeight * 0.04,
                                              screenHeight * 0.068,
                                              screenHeight * 0.01,
                                              dotBKeys,
                                              9,
                                              'B',
                                              9,
                                            ),
                                          ),
                                          Column(
                                            children: _buildContainers(
                                              screenHeight * 0.1,
                                              screenHeight * 0.068,
                                              screenHeight * 0.01,
                                              9,
                                            ),
                                          ),
                                          Column(
                                            children: _buildDotContainers(
                                              screenHeight * 0.04,
                                              screenHeight * 0.068,
                                              screenHeight * 0.01,
                                              dotCKeys,
                                              9,
                                              'C',
                                              18,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.1),
                                          Column(
                                            children: _buildDotContainers(
                                              screenHeight * 0.04,
                                              screenHeight * 0.068,
                                              screenHeight * 0.01,
                                              dotDKeys,
                                              9,
                                              'D',
                                              27,
                                            ),
                                          ),
                                          Column(
                                            children: _buildContainers(
                                              screenHeight * 0.1,
                                              screenHeight * 0.068,
                                              screenHeight * 0.01,
                                              9,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                        ],
                                      ),
                                    ],
                                  ),
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
