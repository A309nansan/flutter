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
import '../../../shared/widgets/header_widget.dart';
import '../../../shared/widgets/new_header_widget.dart';
import '../../../shared/widgets/new_question_text.dart';
import '../../../shared/widgets/question_text.dart';
import '../../../shared/widgets/successful_popup.dart';
import '../../../shared/widgets/toase_message.dart';
import '../controller/level_2_1_1_main1_controller.dart';
import '../widgets/example_popup.dart';
import '../widgets/red_blue_ten_problem.dart';

class LevelTwoOneOneMain1 extends StatefulWidget {
  final String problemCode;

  const LevelTwoOneOneMain1({super.key, required this.problemCode});

  @override
  State<LevelTwoOneOneMain1> createState() => _LevelTwoOneOneMain1State();
}

class _LevelTwoOneOneMain1State extends State<LevelTwoOneOneMain1> with TickerProviderStateMixin {
  late final LevelTwoOneOneMain1Controller controller;
  final screenshotController = ScreenshotController();
  bool isChecked = false;
  bool isSubmitted = false;
  bool isSubmitting = false;
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    controller = LevelTwoOneOneMain1Controller(
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
    controller.clearHandwritingFields();
    setState(() {
      isChecked = false;
    });
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
      ToastMessage.show("이미 제출했어요!");
      return;
    }

    // 인식 수행
    await controller.problemData["firstKey"].currentState?.recognize();
    await controller.problemData["secondKey"].currentState?.recognize();

    // 인식된 값 가져오기
    final firstText = controller.problemData["firstKey"].currentState?.recognizedText ?? '';
    final secondText = controller.problemData["secondKey"].currentState?.recognizedText ?? '';

    // 정답 판별
    final firstCorrect = firstText == controller.problemData["first"].toString();
    final secondCorrect = secondText == controller.problemData["second"].toString();
    final isCorrect = firstCorrect && secondCorrect;

    // 결과 저장
    controller.problemData["firstInput"] = firstText;
    controller.problemData["secondInput"] = secondText;
    controller.problemData["isCorrect"] = isCorrect;

    setState(() {
      isChecked = true;
    });

    Future.delayed(Duration.zero, () async {
      await submitActivity(context);
    });
  }

  Future<void> saveSubmissionData() async {
    if (isSubmitting) return;

    // 인식 수행
    await controller.problemData["firstKey"].currentState?.recognize();
    await controller.problemData["secondKey"].currentState?.recognize();

    // 인식된 값 가져오기
    final firstText = controller.problemData["firstKey"].currentState?.recognizedText ?? '';
    final secondText = controller.problemData["secondKey"].currentState?.recognizedText ?? '';

    // 정답 판별
    final firstCorrect = firstText == controller.problemData["first"].toString();
    final secondCorrect = secondText == controller.problemData["second"].toString();
    final isCorrect = firstCorrect && secondCorrect;

    // 결과 저장
    controller.problemData["firstInput"] = firstText;
    controller.problemData["secondInput"] = secondText;
    controller.problemData["isCorrect"] = isCorrect;

    try {
      setState(() {
        isSubmitting = true;
        controller.showSubmitPopup = true;
      });
      controller.submitController.forward();

      if(!isSubmitted){
        print("ASdasd");
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
                    height: h * 0.85,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              NewHeaderWidget(
                                  headerText: "주요학습활동",
                                  headerTextSize: w * 0.028,
                                  subTextSize: w * 0.018
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: NewQuestionTextWidget(
                                      questionText: "10이 어떻게 만들어졌는지 숫자로 나타내봅시다.",
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
                        SizedBox(height: h * 0.15),
                        RedBlueTenProblem(
                          index: 0,
                          first: controller.problemData["first"],
                          second: controller.problemData["second"],
                          firstKey: controller.problemData["firstKey"],
                          secondKey: controller.problemData["secondKey"],
                          result: controller.problemData["isCorrect"],
                          onClear: clearAnswer,
                          isChecked: isChecked,
                          setIsChecked: () => setState(() => isChecked = true),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
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
                        child: ExamplePopup(
                          scaleAnimation: const AlwaysStoppedAnimation(1.0),
                          onClose: controller.closeSample,
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
