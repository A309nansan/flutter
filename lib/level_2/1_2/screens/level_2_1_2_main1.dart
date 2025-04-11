import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/level_2/1_2/controller/level_2_1_2_main1_controller.dart';
import 'package:nansan_flutter/level_2/1_2/widgets/compare_number_card.dart';
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
import '../widgets/pattern_fill_board.dart';
import '../widgets/pattern_selector.dart';
import '../widgets/main1_sample_popup.dart';

class LevelTwoOneTwoMain1 extends StatefulWidget {
  final String problemCode;

  const LevelTwoOneTwoMain1({super.key, required this.problemCode});

  @override
  State<LevelTwoOneTwoMain1> createState() => _LevelTwoOneTwoMain1State();
}

class _LevelTwoOneTwoMain1State extends State<LevelTwoOneTwoMain1>
    with TickerProviderStateMixin {
  late final LevelTwoOneTwoMain1Controller controller;
  final ScreenshotController screenshotController = ScreenshotController();
  bool isSubmitted = false;
  bool isSubmitting = false;
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    controller = LevelTwoOneTwoMain1Controller(
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (!controller.isInitialized) {
      return EnProblemSplashScreen();
    }

    final problem = controller.problemData;
    final isChecked = controller.isInputComplete;
    final nextCode = controller.originalProblem["next_problem_code"] as String?;
    final isEnd = nextCode == null || nextCode.isEmpty;

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
                    height: screenHeight * 0.83,
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            height: screenHeight * 0.15,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  NewHeaderWidget(
                                      headerText: "주요학습활동1",
                                      headerTextSize: screenWidth * 0.028,
                                      subTextSize: screenWidth * 0.018
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: NewQuestionTextWidget(
                                          questionText: "숫자만큼 무늬를 채우고, 슷자보다 '1 큰 수'를 골라 선택해 보세요.",
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
                          ),
                          SizedBox(height: screenHeight * 0.15),
                          Container(
                            width: screenWidth * 0.9,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 4,
                                  child: Column(
                                    children: [
                                      Text(
                                        "숫자",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.025,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      SizedBox(
                                        width: screenWidth * 0.35,
                                        height: screenHeight * 0.1,
                                        child: Card(
                                          elevation: 3,
                                          color: Colors.white,
                                          child: Center(
                                            child: Text(
                                              "${problem["value"]}",
                                              style: TextStyle(
                                                fontSize: 50,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 26),
                                      Text(
                                        "'1 큰 수' 찾기",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CompareNumberCard(
                                            number: problem["left"],
                                            isSelected: controller.lCardSelected,
                                            isCorrect: controller.lCardCorrect,
                                            isWrong: controller.lCardWrong,
                                            controller: controller.lCardController,
                                            onPressed: () => controller.onCardPressed(true),
                                          ),
                                          SizedBox(width: 20),
                                          CompareNumberCard(
                                            number: problem["right"],
                                            isSelected: controller.rCardSelected,
                                            isCorrect: controller.rCardCorrect,
                                            isWrong: controller.rCardWrong,
                                            controller: controller.rCardController,
                                            onPressed: () => controller.onCardPressed(false),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 5,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "숫자만큼 무늬 채우기",
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.025,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          PatternSelector(
                                            selected: controller.selectedPattern,
                                            onSelected: (pattern) {
                                              controller.selectedPattern = pattern;
                                              controller.onUpdate();
                                            },
                                          ),
                                        ],
                                      ),
                                      PatternFillBoard(
                                        pattern: controller.selectedPattern,
                                        filledCount: controller.filledCount,
                                        onChanged: (newCount) {
                                          controller.filledCount = newCount;
                                          controller.problemData["secondInput"] = newCount;

                                          final isCorrect = newCount == controller.problemData["value"];
                                          controller.updatePatternCorrect(isCorrect);
                                        },

                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                SizedBox(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: screenHeight * 0.02),
                        child: EnProgressBarWidget(
                            current: controller.currentProblemNumber,
                            total: controller.totalProblemCount
                        ),
                      ),
                      AnimatedSwitcher(
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
                    ],
                  ),
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
                      child: GestureDetector(
                        onTap: () {},
                        child: ScaleTransition(
                          scale: controller.popAnimation,
                          child: Main1SamplePopup(
                            scaleAnimation: const AlwaysStoppedAnimation(1.0),
                            onClose: controller.closeSample,
                            desc: "💡 다음의 숫자만큼 좋아하는 무늬를 선택하여 채워보고, '1 큰 수'를 찾아 동그라미해 보세요.",
                          ),
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