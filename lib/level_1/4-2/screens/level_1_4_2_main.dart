import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nansan_flutter/modules/level_api/services/problem_api_service.dart';
import 'package:screenshot/screenshot.dart';
import '../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../../shared/provider/EnRiverPodProvider.dart';
import '../../../shared/services/en_problem_service.dart';
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
import '../controller/level_1_4_2_main_controller.dart';
import '../widgets/main_sample_popup.dart';

class LevelOneFourTwoMain extends ConsumerStatefulWidget {
  final String problemCode;

  const LevelOneFourTwoMain({super.key, required this.problemCode});

  @override
  ConsumerState<LevelOneFourTwoMain> createState() => _LevelOneFourTwoMainState();
}

class _LevelOneFourTwoMainState extends ConsumerState<LevelOneFourTwoMain> with TickerProviderStateMixin {
  late final LevelOneFourTwoMainController controller;
  final ScreenshotController screenshotController = ScreenshotController();
  bool isSubmitted = false;
  bool isSubmitting = false;
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    controller = LevelOneFourTwoMainController(
      ticker: this,
      onUpdate: () => setState(() {}),
      ref: ref,
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

  void handleSubmitClick() async {
    if (isSubmitted) {
      ToastMessage.show("이미 제출했습니다!");
      return;
    }

    await controller.problemData["leftKey"].currentState?.recognize();
    await controller.problemData["rightKey"].currentState?.recognize();
    await controller.problemData["valueKey"].currentState?.recognize();
    await controller.problemData["resultKey"].currentState?.recognize();

    final leftText = controller.problemData["leftKey"].currentState?.recognizedText ?? '';
    final rightText = controller.problemData["rightKey"].currentState?.recognizedText ?? '';
    final valueText = controller.problemData["valueKey"].currentState?.recognizedText ?? '';
    final resultText = controller.problemData["resultKey"].currentState?.recognizedText ?? '';

    controller.updateUserInput(
      left: int.tryParse(leftText),
      right: int.tryParse(rightText),
      value: int.tryParse(valueText),
      result: int.tryParse(resultText),
    );
    controller.isChecked = true;

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

    await controller.problemData["leftKey"].currentState?.recognize();
    await controller.problemData["rightKey"].currentState?.recognize();
    await controller.problemData["valueKey"].currentState?.recognize();
    await controller.problemData["resultKey"].currentState?.recognize();

    final leftText = controller.problemData["leftKey"].currentState?.recognizedText ?? '';
    final rightText = controller.problemData["rightKey"].currentState?.recognizedText ?? '';
    final valueText = controller.problemData["valueKey"].currentState?.recognizedText ?? '';
    final resultText = controller.problemData["resultKey"].currentState?.recognizedText ?? '';

    controller.updateUserInput(
      left: int.tryParse(leftText),
      right: int.tryParse(rightText),
      value: int.tryParse(valueText),
      result: int.tryParse(resultText),
    );

    try {
      setState(() {
        isSubmitting = true;
        controller.showSubmitPopup = true;
      });
      controller.submitController.forward();

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

        ref.read(problemProgressProvider.notifier).record(
          controller.problemCode,
          controller.showCorrect,
        );

        await EnProblemService.saveProblemResults(
          ref.read(problemProgressProvider),
          controller.problemCode,
          controller.childId,
        );

        setState(() {
          isSubmitted = true;
          isCorrectAnswer = controller.showCorrect;
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

    final problem = controller.problemData;
    final isEnd = controller.originalProblem["next_problem_code"]?.isEmpty ?? true;

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
                    height: height * 0.85,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              NewHeaderWidget(
                                headerText: "주요학습활동",
                                headerTextSize: width * 0.028,
                                subTextSize: width * 0.018,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: NewQuestionTextWidget(
                                      questionText: "다음 수만큼 묶어 보고, 각 네모 칸에 알맞은 숫자를 적어봅시다.",
                                      questionTextSize: width * 0.03,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: controller.showSample,
                                    icon: Icon(
                                      Icons.lightbulb,
                                      size: width * 0.04,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "다음의 모양 ${problem["left"]}개를 묶어보고, 각 네모 칸에 알맞은 숫자를 써봅시다.",
                                style: TextStyle(fontSize: width * 0.025, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                tooltip: "전체 초기화",
                                onPressed: controller.clearAnswer,
                                icon: Icon(Icons.refresh, size: width * 0.04),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            height: height * 0.15,
                            width: width * 0.6,
                            child: GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 5,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              childAspectRatio: 1,
                              children: List.generate(10, (i) {
                                final isLeft = i < problem["left"];
                                final isRight = i >= 5 && (i - 5) < problem["right"];

                                Color? color;
                                if (i < 5) {
                                  color = isLeft ? Colors.yellow : Colors.grey[200];
                                } else {
                                  color = isRight ? Colors.green : Colors.grey[200];
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),


                        const SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: ["leftKey", "rightKey"].map((key) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                                    child: Stack(
                                      children: [
                                        HandwritingRecognitionZone(
                                          key: problem[key],
                                          width: width * 0.17,
                                          height: height * 0.1,
                                        ),
                                        Positioned(
                                          right: -10,
                                          top: -10,
                                          child: IconButton(
                                            icon: const Icon(Icons.clear, size: 20),
                                            onPressed: () => controller.clearSingleField(key.replaceAll("Key", "")),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: pi / 4,
                                    child: Icon(Icons.arrow_right_alt_rounded, size: height * 0.06, color: Colors.blueAccent),
                                  ),
                                  const SizedBox(width: 80),
                                  Transform.rotate(
                                    angle: pi / 1.35,
                                    child: Icon(Icons.arrow_right_alt_rounded, size: height * 0.06, color: Colors.blueAccent),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Stack(
                                children: [
                                  HandwritingRecognitionZone(
                                    key: problem["valueKey"],
                                    width: width * 0.17,
                                    height: height * 0.1,
                                  ),
                                  Positioned(
                                    right: -10,
                                    top: -10,
                                    child: IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () => controller.clearSingleField("value"),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${problem["value"]}는 ${problem["left"]}와 ",
                              style: TextStyle(fontSize: width * 0.035, fontWeight: FontWeight.bold),
                            ),
                            Stack(
                              children: [
                                HandwritingRecognitionZone(
                                  key: problem["resultKey"],
                                  width: width * 0.17,
                                  height: height * 0.1,
                                ),
                                Positioned(
                                  right: -10,
                                  top: -10,
                                  child: IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () => controller.clearSingleField("result"),
                                  ),
                                )
                              ],
                            ),
                            Text(
                              " (으)로 모을 수 있습니다.",
                              style: TextStyle(fontSize: width * 0.035, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: height * 0.02),
                      child: EnProgressBarWidget(
                          current: controller.currentProblemNumber,
                          total: controller.totalProblemCount
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: height * 0.02),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Row(
                          key: ValueKey<String>('${isSubmitted}_${controller.showCorrect}'),
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
                  ],
                ),
              ],
            ),
          ),
          if (controller.isShowSample)
            Positioned.fill(
              child: FadeTransition(
                opacity: controller.popAnimation,
                child: GestureDetector(
                  onTap: controller.closeSample,
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: ScaleTransition(
                        scale: controller.popAnimation,
                        child: MainSamplePopup(
                          scaleAnimation: const AlwaysStoppedAnimation(1.0),
                          onClose: controller.closeSample,
                          desc: "💡 다음 수 대로 묶어 봅시다. 각 네모 칸에 알맞은 숫자를 적어봅시다.",
                        ),
                      ),
                    ),
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
                            isCorrect: controller.showCorrect,
                            customMessage: controller.showCorrect ? "🎉 정답이에요!" : "틀렸어요...",
                            isEnd: isEnd,
                            closePopup: controller.closeSubmit,
                            onClose: controller.showCorrect ? () async => controller.onNextPressed() : null,
                            end: () async => controller.onNextPressed()
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
