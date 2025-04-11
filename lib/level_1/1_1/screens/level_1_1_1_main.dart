import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/level_1/1_1/controllers/level_1_1_1_main_controller.dart';
import 'package:nansan_flutter/level_1/1_1/widgets/answer_grid_item.dart';
import 'package:nansan_flutter/shared/widgets/appbar_widget.dart';
import 'package:nansan_flutter/shared/widgets/button_widget.dart';
import 'package:nansan_flutter/shared/widgets/en_problem_splash_screen.dart';
import 'package:nansan_flutter/shared/widgets/en_progress_bar_widget.dart';
import 'package:nansan_flutter/shared/widgets/new_header_widget.dart';
import 'package:nansan_flutter/shared/widgets/new_question_text.dart';
import 'package:nansan_flutter/shared/widgets/successful_popup.dart';
import 'package:screenshot/screenshot.dart';

class LevelOneOneOneMain extends StatefulWidget {
  final String problemCode;
  const LevelOneOneOneMain({super.key, required this.problemCode});

  @override
  State<StatefulWidget> createState() => _LevelOneOneOneMainState();
}

class _LevelOneOneOneMainState extends State<LevelOneOneOneMain>
    with TickerProviderStateMixin {
  late LevelOneOneOneController controller;
  late AnimationController submitController;
  late Animation<double> submitAnimation;
  bool showSubmitPopup = false;

  @override
  void initState() {
    super.initState();
    controller = LevelOneOneOneController(problemCode: widget.problemCode);

    submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    submitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: submitController, curve: Curves.elasticOut),
    );

    // 상태 변경 리스너 추가
    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    submitController.dispose();
    controller.dispose();
    super.dispose();
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
          controller.candidates.isEmpty
              ? const Center(child: EnProblemSplashScreen())
              : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Screenshot(
                      controller: controller.screenshotController,
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NewHeaderWidget(
                              headerText: '주요학습활동',
                              headerTextSize: screenWidth * 0.028,
                              subTextSize: screenWidth * 0.018,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            NewQuestionTextWidget(
                              questionText:
                                  '${controller.targetNumber}${controller.eulrul(controller.targetNumber)} 나타내는 모든 그림을 찾아 클릭하세요.',
                              questionTextSize: screenWidth * 0.03,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Expanded(
                              flex: 8,
                              child: GridView.count(
                                crossAxisCount: 3,
                                padding: const EdgeInsets.all(10),
                                children:
                                    controller.candidates
                                        .map(
                                          (c) => AnswerGridItemWidget(
                                            candidate: c,
                                            selectedAnswers:
                                                controller.selectedAnswers,
                                            onSelectionChanged:
                                                (key) => controller
                                                    .handleSelection(key),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                EnProgressBarWidget(
                                  current: controller.current,
                                  total: controller.total,
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
                                        '${controller.isSubmitted}_${controller.isCorrect}',
                                      ),
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (!controller.isSubmitted)
                                          ButtonWidget(
                                            height: screenHeight * 0.035,
                                            width: screenWidth * 0.18,
                                            buttonText: "제출하기",
                                            fontSize: screenWidth * 0.02,
                                            borderRadius: 10,
                                            onPressed:
                                                (controller.isSubmitted)
                                                    ? null
                                                    : () => {
                                                      submitController
                                                          .forward(),
                                                      showSubmitPopup = true,
                                                      controller.submitActivity(
                                                        context,
                                                      ),
                                                      controller.checkAnswer(),
                                                    },
                                          ),

                                        if (controller.isSubmitted &&
                                            controller.isCorrect == false) ...[
                                          ButtonWidget(
                                            height: screenHeight * 0.035,
                                            width: screenWidth * 0.18,
                                            buttonText: "제출하기",
                                            fontSize: screenWidth * 0.02,
                                            borderRadius: 10,
                                            onPressed:
                                                () => {
                                                  controller.checkAnswer(),
                                                  submitController.forward(),
                                                  showSubmitPopup = true,
                                                },
                                          ),
                                          const SizedBox(width: 20),
                                          ButtonWidget(
                                            height: screenHeight * 0.035,
                                            width: screenWidth * 0.18,
                                            buttonText:
                                                controller.isEnd
                                                    ? "학습종료"
                                                    : "다음문제",
                                            fontSize: screenWidth * 0.02,
                                            borderRadius: 10,
                                            onPressed:
                                                () =>
                                                    controller.onNextPressed(),
                                          ),
                                        ],

                                        if (controller.isSubmitted &&
                                            controller.isCorrect == true)
                                          ButtonWidget(
                                            height: screenHeight * 0.035,
                                            width: screenWidth * 0.18,
                                            buttonText:
                                                controller.isEnd
                                                    ? "학습종료"
                                                    : "다음문제",
                                            fontSize: screenWidth * 0.02,
                                            borderRadius: 10,
                                            onPressed:
                                                () =>
                                                    controller.onNextPressed(),
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
                                    isCorrect: controller.isCorrect,
                                    customMessage:
                                        controller.isCorrect
                                            ? "🎉 정답이에요!"
                                            : "틀렸어요...",
                                    isEnd: controller.isEnd,
                                    closePopup: closeSubmit,
                                    onClose:
                                        controller.isCorrect
                                            ? () async =>
                                                controller.onNextPressed()
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
