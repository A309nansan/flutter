import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:screenshot/screenshot.dart';
import '../../../modules/level_api/services/problem_api_service.dart';
import '../../../shared/services/image_service.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/appbar_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/en_problem_splash_screen.dart';
import '../../../shared/widgets/en_progress_bar_widget.dart';
import '../../../shared/widgets/new_header_widget.dart';
import '../../../shared/widgets/new_question_text.dart';
import '../../../shared/widgets/successful_popup.dart';
import '../../../shared/widgets/toase_message.dart';
import '../controller/level_2_1_2_main2_controller.dart';
import '../widgets/main2_sample_popup.dart';
import '../widgets/stacked_block.dart';

class LevelTwoOneTwoMain2 extends StatefulWidget {
  final String problemCode;

  const LevelTwoOneTwoMain2({super.key, required this.problemCode});

  @override
  State<LevelTwoOneTwoMain2> createState() => _LevelTwoOneTwoMain2State();
}

class _LevelTwoOneTwoMain2State extends State<LevelTwoOneTwoMain2>
    with TickerProviderStateMixin {
  late final LevelTwoOneTwoMain2Controller controller;
  final ScreenshotController screenshotController = ScreenshotController();
  bool isSubmitted = false;
  bool isSubmitting = false;
  bool isCorrectAnswer = false;


  @override
  void initState() {
    super.initState();
    controller = LevelTwoOneTwoMain2Controller(
      ticker: this,
      onUpdate: () => setState(() {}),
    );
    controller.init(widget.problemCode);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> submitActivity(BuildContext context) async {
    try {
      final imageBytes = await screenshotController.capture();
      if (imageBytes == null || !context.mounted) return;

      controller.submissionTime = DateTime.now();

      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      final childId = childProfile['id'];

      await ImageService.uploadImage(
        imageBytes: imageBytes,
        childId: childId,
        localDateTime: controller.submissionTime!,
      );

      setState(() {
        controller.showSubmitPopup = true;
      });
      controller.submitController.forward();
    } catch (e) {
      debugPrint("이미지 캡처 중 오류 발생: $e");
    }
  }

  Future<void> saveSubmissionData() async {
    if (isSubmitting) return;

    try {
      setState(() {
        isSubmitting = true;
        controller.showSubmitPopup = true;
      });
      controller.submitController.forward();

      if(!isSubmitted) {
        final childProfileJson = await SecureStorageService.getChildProfile();
        final childProfile = jsonDecode(childProfileJson!);
        final childId = childProfile['id'];
        controller.submissionTime ??= DateTime.now();

        final result = controller.buildResultJson(
          dateTime: controller.submissionTime!,
          childId: childId,
        );

        await ProblemApiService().submitAnswer(result);

        setState(() {
          isSubmitted = true;
          isCorrectAnswer = controller.isCorrect;
        });
      }
    } catch (e) {
      setState(() {
        isSubmitted = true;
      });
      debugPrint("제출 저장 중 오류 발생: $e");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (!controller.isInitialized) {
      return EnProblemSplashScreen();
    }

    final problem = controller.problemData;
    final isChecked = controller.isInputComplete;
    final isEnd = (controller.originalProblem["next_problem_code"] as String?)?.isEmpty ?? true;

    return Scaffold(
      appBar: AppbarWidget(
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40.0),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Screenshot(
                  controller: screenshotController,
                  child: Container(
                    height: screenHeight * 0.85,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              NewHeaderWidget(
                                  headerText: "주요학습활동2",
                                  headerTextSize: screenWidth * 0.028,
                                  subTextSize: screenWidth * 0.018
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: NewQuestionTextWidget(
                                      questionText: "숫자보다 1 작은 수만큼 ■가 있는 칸을 찾아 선택해 보세요.",
                                      questionTextSize: screenWidth * 0.03,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: controller.showSample,
                                    icon: Icon(
                                      Icons.lightbulb,
                                      size: 30,
                                      color: Colors.yellow,
                                      shadows: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(77),
                                          blurRadius: 3,
                                          offset: const Offset(1, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Card(
                          elevation: 10,
                          color: const Color(0xFFFFFDEC),
                          child: SizedBox(
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.15,
                            child: Center(
                              child: Text(
                                "${problem["value"]}",
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            StackedBlock(
                              number: problem["left"],
                              isSelected: controller.lCardSelected,
                              isCorrect: controller.lCardCorrect,
                              isWrong: controller.lCardWrong,
                              controller: controller.lCardController,
                              onPressed: () => controller.onCardPressed(true),
                            ),
                            const SizedBox(height: 20),
                            StackedBlock(
                              number: problem["right"],
                              isSelected: controller.rCardSelected,
                              isCorrect: controller.rCardCorrect,
                              isWrong: controller.rCardWrong,
                              controller: controller.rCardController,
                              onPressed: () => controller.onCardPressed(false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: screenHeight * 0.02),
                      child: EnProgressBarWidget(
                          current: controller.currentProblemNumber,
                          total: controller.totalProblemCount
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: screenHeight * 0.02),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Row(
                          key: ValueKey<String>('${isSubmitted}_${controller.isCorrect}'),
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isSubmitted)
                              ButtonWidget(
                                height: screenHeight * 0.035,
                                width: screenWidth * 0.18,
                                buttonText: "제출하기",
                                fontSize: screenWidth * 0.02,
                                borderRadius: 10,
                                onPressed: (isSubmitting || isSubmitted) ? null : saveSubmissionData,
                              ),

                            if (isSubmitted && isCorrectAnswer == false)
                              ...[
                                ButtonWidget(
                                  height: screenHeight * 0.035,
                                  width: screenWidth * 0.18,
                                  buttonText: "제출하기",
                                  fontSize: screenWidth * 0.02,
                                  borderRadius: 10,
                                  onPressed: saveSubmissionData,
                                ),
                                const SizedBox(width: 20),
                                ButtonWidget(
                                  height: screenHeight * 0.035,
                                  width: screenWidth * 0.18,
                                  buttonText: isEnd ? "학습종료" : "다음문제",
                                  fontSize: screenWidth * 0.02,
                                  borderRadius: 10,
                                  onPressed: () => controller.onNextPressed(),
                                ),
                              ],

                            if (isSubmitted && isCorrectAnswer == true)
                              ButtonWidget(
                                height: screenHeight * 0.035,
                                width: screenWidth * 0.18,
                                buttonText: isEnd ? "학습종료" : "다음문제",
                                fontSize: screenWidth * 0.02,
                                borderRadius: 10,
                                onPressed: () => controller.onNextPressed(),
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

          // 샘플 팝업
          if (controller.isShowSample)
            Positioned.fill(
              child: GestureDetector(
                onTap: controller.closeSample,
                child: FadeTransition(
                  opacity: controller.popAnimation,
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: ScaleTransition(
                        scale: controller.popAnimation,
                        child: Main2SamplePopup(
                          scaleAnimation: const AlwaysStoppedAnimation(1.0),
                          onClose: controller.closeSample,
                          desc: "💡 숫자보다 '1 작은 수' 또는 '1 큰 수'를 찾아 선택해 보세요.",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 제출 팝업
          if (controller.showSubmitPopup)
            Positioned.fill(
              child: Stack(
                children: [
                  Container(color: Colors.black54),
                  Center(
                    child: FadeTransition(
                      opacity: controller.submitAnimation,
                      child: ScaleTransition(
                        scale: controller.submitAnimation,
                        child: Material(
                          type: MaterialType.transparency,
                          child: SuccessfulPopup(
                            scaleAnimation: const AlwaysStoppedAnimation(1.0),
                            isCorrect: controller.isCorrect,
                            customMessage: controller.isCorrect ? "🎉 정답이에요!" : "틀렸어요...",
                            isEnd: isEnd,
                            closePopup: controller.closeSubmit,
                            onClose: controller.isCorrect? () async => controller.onNextPressed() : null,
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
