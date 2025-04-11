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
import '../controller/level_2_1_1_think2_controller.dart';
import '../widgets/number_card.dart';

class LevelTwoOneOneThink2 extends StatefulWidget {
  final String problemCode;

  const LevelTwoOneOneThink2({super.key, required this.problemCode});

  @override
  State<LevelTwoOneOneThink2> createState() => _LevelTwoOneOneThink2PageState();
}

class _LevelTwoOneOneThink2PageState extends State<LevelTwoOneOneThink2> with TickerProviderStateMixin {
  late final LevelTwoOneOneThink2Controller controller;
  final ScreenshotController screenshotController = ScreenshotController();
  bool isSubmitted = false;
  bool isSubmitting = false;
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    controller = LevelTwoOneOneThink2Controller(
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

  void handleSubmitClick() {
    if (isSubmitted) {
      ToastMessage.show("이미 제출했어요!");
      return;
    }

    controller.isCorrect = controller.cardCorrect.where((e) => e).length == controller.correctTarget;

    setState(() {
      controller.showSubmitPopup = true;
    });
    controller.submitController.forward();

    Future.delayed(Duration.zero, () async {
      await submitActivity(context);
    });
  }

  Future<void> saveSubmissionData() async {
    if (isSubmitting) return;

    try {
      setState(() {
        isSubmitting = true;
        controller.showSubmitPopup = true;
      });
      controller.submitController.forward();

      controller.isCorrect = controller.cardCorrect.where((e) => e).length == controller.correctTarget;

      if(!isSubmitted){
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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    if (!controller.isInitialized) {
      return EnProblemSplashScreen();
    }

    final isEnd = (controller.originalProblem["next_problem_code"] as String?)?.isEmpty ?? true;

    return Scaffold(
      appBar: AppbarWidget(
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40),
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
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              NewHeaderWidget(
                                  headerText: "개념학습활동",
                                  headerTextSize: w * 0.028,
                                  subTextSize: w * 0.018
                              ),
                              NewQuestionTextWidget(
                                questionText: "10을 나타내는 것을 모두 찾아 선택해 보세요.",
                                questionTextSize: w * 0.03,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: w * 0.95,
                          height: h * 0.75,
                          color: Colors.white,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.problemData.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.77,
                            ),
                            itemBuilder: (_, i) => NumberCard(
                              problem: controller.problemData[i],
                              isSelected: controller.cardSelected[i],
                              isCorrect: controller.cardCorrect[i],
                              controller: controller.cardControllers[i],
                              onPressed: () => controller.onCardPressed(i),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: EnProgressBarWidget(
                          current: controller.currentProblemNumber,
                          total: controller.totalProblemCount
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: h * 0.015),
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
                                height: h * 0.035,
                                width: w * 0.18,
                                buttonText: "제출하기",
                                fontSize: w * 0.02,
                                borderRadius: 10,
                                onPressed: (isSubmitting || isSubmitted) ? null : saveSubmissionData,
                              ),

                            if (isSubmitted && isCorrectAnswer == false)
                              ...[
                                ButtonWidget(
                                  height: h * 0.035,
                                  width: w * 0.18,
                                  buttonText: "제출하기",
                                  fontSize: w * 0.02,
                                  borderRadius: 10,
                                  onPressed: saveSubmissionData,
                                ),
                                const SizedBox(width: 20),
                                ButtonWidget(
                                  height: h * 0.035,
                                  width: w * 0.18,
                                  buttonText: isEnd ? "학습종료" : "다음문제",
                                  fontSize: w * 0.02,
                                  borderRadius: 10,
                                  onPressed: () => controller.onNextPressed(),
                                ),
                              ],

                            if (isSubmitted && isCorrectAnswer == true)
                              ButtonWidget(
                                height: h * 0.035,
                                width: w * 0.18,
                                buttonText: isEnd ? "학습종료" : "다음문제",
                                fontSize: w * 0.02,
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