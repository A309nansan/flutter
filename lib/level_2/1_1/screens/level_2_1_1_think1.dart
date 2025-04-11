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
import '../controller/level_2_1_1_think1_controller.dart';
import '../widgets/dot_connector.dart';

class LevelTwoOneOneThink1 extends StatefulWidget {
  final String problemCode;

  const LevelTwoOneOneThink1({super.key, required this.problemCode});

  @override
  State<LevelTwoOneOneThink1> createState() => _LevelTwoOneOneThink1State();
}

class _LevelTwoOneOneThink1State extends State<LevelTwoOneOneThink1>
    with TickerProviderStateMixin {
  late final LevelTwoOneOneThink1Controller controller;
  final ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey<DotConnectorState> dotConnectorKey = GlobalKey<DotConnectorState>();
  bool isSubmitted = false;
  bool isSubmitting = false;
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    controller = LevelTwoOneOneThink1Controller(
      ticker: this,
      onUpdate: () => setState(() {}),
      dotConnectorKey: dotConnectorKey,
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

      isCorrectAnswer = controller.problemLines.every((l) => l.isCorrect);

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
          isCorrectAnswer = controller.problemLines.every((l) => l.isCorrect);
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (!controller.isInitialized) {
      return EnProblemSplashScreen();
    }

    final isEnd = controller.originalProblem.nextProblemCode?.isEmpty ?? true;

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
          Screenshot(
            controller: screenshotController,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        NewHeaderWidget(
                            headerText: "개념학습활동",
                            headerTextSize: width * 0.028,
                            subTextSize: height * 0.018
                        ),
                        NewQuestionTextWidget(
                          questionText: "10이 되도록 짝을 찾아 이어보세요.",
                          questionTextSize: width * 0.03,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: width * 0.85,
                        child: DotConnector(
                          key: dotConnectorKey,
                          controller: controller,
                          onMatched: controller.updateMatch,
                          onWrong: controller.triggerWrongAnimation,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            left: 10,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: EnProgressBarWidget(
                  current: controller.currentProblemNumber,
                  total: controller.totalProblemCount
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 50,
            child: Padding(
              padding: EdgeInsets.zero,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Row(
                  key: ValueKey<String>('${isSubmitted}_${controller.problemLines.every((l) => l.isCorrect)}'),
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isSubmitted)
                      ButtonWidget(
                        height: height * 0.035,
                        width: width * 0.18,
                        buttonText: "제출하기",
                        fontSize: width * 0.02,
                        borderRadius: 10,
                        onPressed: (isSubmitting || isSubmitted) ? null : saveSubmissionData,
                      ),

                    if (isSubmitted && isCorrectAnswer == false)
                      ...[
                        ButtonWidget(
                          height: height * 0.035,
                          width: width * 0.18,
                          buttonText: "제출하기",
                          fontSize: width * 0.02,
                          borderRadius: 10,
                          onPressed: saveSubmissionData,
                        ),
                        const SizedBox(width: 20),
                        ButtonWidget(
                          height: height * 0.035,
                          width: width * 0.18,
                          buttonText: isEnd ? "학습종료" : "다음문제",
                          fontSize: width * 0.02,
                          borderRadius: 10,
                          onPressed: () => controller.onNextPressed(),
                        ),
                      ],

                    if (isSubmitted && isCorrectAnswer == true)
                      ButtonWidget(
                        height: height * 0.035,
                        width: width * 0.18,
                        buttonText: isEnd ? "학습종료" : "다음문제",
                        fontSize: width * 0.02,
                        borderRadius: 10,
                        onPressed: () => controller.onNextPressed(),
                      ),
                  ],
                ),
              ),
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
                            isCorrect: controller.problemLines.every((l) => l.isCorrect),
                            customMessage: controller.problemLines.every((l) => l.isCorrect) ? "🎉 정답이에요!" : "틀렸어요...",
                            isEnd: isEnd,
                            closePopup: controller.closeSubmit,
                            onClose: controller.problemLines.every((l) => l.isCorrect) ? () async => controller.onNextPressed() : null,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
