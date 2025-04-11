import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/shared/services/request_service.dart';
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
import '../controller/level_2_1_2_think_controller.dart';
import '../widgets/drag_group_widget.dart';
import '../widgets/hand_write_widget.dart';
import '../widgets/think_sample_popup.dart';

class LevelTwoOneTwoThink extends StatefulWidget {
  final String problemCode;
  const LevelTwoOneTwoThink({super.key, required this.problemCode});

  @override
  State<LevelTwoOneTwoThink> createState() => _LevelTwoOneTwoThinkState();
}

class _LevelTwoOneTwoThinkState extends State<LevelTwoOneTwoThink>
    with TickerProviderStateMixin {
  late final LevelTwoOneTwoThinkController controller;
  final screenshotController = ScreenshotController();
  bool isSubmitted = false;
  bool isSubmitting = false;
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    controller = LevelTwoOneTwoThinkController(
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

  void clearAnswer() {
    controller.problemData["tenKey"].currentState?.clear();
    controller.problemData["oneKey"].currentState?.clear();
    setState(() {
      controller.problemData["isChecked"] = false;
      controller.problemData["isCorrect"] = false;
    });
  }

  void evaluateAnswer() {
    final data = controller.problemData;

    final ten = data["tenKey"].currentState?.recognizedText ?? '';
    final one = data["oneKey"].currentState?.recognizedText ?? '';
    final combined = "$ten$one";

    final writingCorrect = combined == data["value"].toString();
    final dragCorrect = data["selectedCount"] == 10;

    setState(() {
      data["isChecked"] = true;
      data["isCorrect"] = writingCorrect;
    });

    controller.updateCorrectStatus(
      isWritingCorrect: writingCorrect,
      isDragCorrect: dragCorrect,
    );
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

  }

  Future<void> saveSubmissionData() async {
    if (isSubmitting) return;

    final data = controller.problemData;
    final tenKey = data["tenKey"].currentState;
    final oneKey = data["oneKey"].currentState;

    final ten = await tenKey?.recognize();
    final one = await oneKey?.recognize();

    final combined = "${ten ?? ''}${one ?? ''}";
    final writingCorrect = combined == data["value"].toString();
    final dragCorrect = data["selectedCount"] == 10;

    setState(() {
      data["isChecked"] = true;
      data["isCorrect"] = writingCorrect;
      // isCorrectAnswer = writingCorrect && dragCorrect;
    });

    controller.updateCorrectStatus(
      isWritingCorrect: writingCorrect,
      isDragCorrect: dragCorrect,
    );

    isCorrectAnswer = controller.problemData["isCorrect"];

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
          isCorrectAnswer = controller.problemData["isCorrect"];
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

    final data = controller.problemData;
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
                    height: h * 0.83,
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
                              Row(
                                children: [
                                  Expanded(
                                    child: NewQuestionTextWidget(
                                      questionText: "11 ~ 19의 숫자를 따라 쓰고, 10개씩 묶어보세요.",
                                      questionTextSize: w * 0.03,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: controller.showSample,
                                    icon: Icon(
                                      Icons.lightbulb,
                                      size: w * 0.04,
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
                        const SizedBox(height: 16),
                        HandWriteWidget(
                          index: 0,
                          number: data["value"],
                          numberText: data["number_text"],
                          tenKey: data["tenKey"],
                          oneKey: data["oneKey"],
                          result: data["isCorrect"],
                          onClear: clearAnswer,
                          onRecognitionComplete: () {
                            final ten = data["tenKey"].currentState?.recognizedText ?? '';
                            final one = data["oneKey"].currentState?.recognizedText ?? '';
                            final combined = "$ten$one";
                            final writingCorrect = combined == data["value"].toString();

                            setState(() {
                              data["isChecked"] = true;
                              data["isCorrect"] = writingCorrect;
                            });

                            controller.updateCorrectStatus(
                              isWritingCorrect: writingCorrect,
                              isDragCorrect: data["selectedCount"] == 10,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        GridDragGroupWidget(
                          key: data["gridKey"],
                          itemCount: data["value"],
                          imagePath: data["img"],
                          crossAxisCount: 5,
                          onSelectionChanged: (count) => setState(() => data["selectedCount"] = count),
                          onDragFinished: (count) {
                            setState(() => data["selectedCount"] = count);
                            controller.updateCorrectStatus(
                              isWritingCorrect: data["isCorrect"],
                              isDragCorrect: count == 10,
                            );
                          },
                          onReset: clearAnswer,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: w * 0.8,
                          child: Text("선택 ${data["selectedCount"] ?? 0}개",
                              style: TextStyle(fontSize: w * 0.025, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                // const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: h * 0.02),
                      child: EnProgressBarWidget(
                          current: controller.currentProblemNumber,
                          total: controller.totalProblemCount
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: h * 0.02),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Row(
                          key: ValueKey<String>('${isSubmitted}_${controller.problemData["isCorrect"]}'),
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
                        child: ThinkSamplePopup(
                          scaleAnimation: const AlwaysStoppedAnimation(1.0),
                          onClose: controller.closeSample,
                          desc: "💡 숫자를 따라 쓰고, 드래그하여 10묶음과 낱개로 나눠주세요.",
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
                            isCorrect: controller.problemData["isCorrect"],
                            customMessage: controller.problemData["isCorrect"] ? "🎉 정답이에요!" : "틀렸어요...",
                            isEnd: isEnd,
                            closePopup: controller.closeSubmit,
                            onClose: controller.problemData["isCorrect"]? () async => controller.onNextPressed() : null,
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
