import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/shared/widgets/new_header_widget.dart';
import 'package:nansan_flutter/shared/widgets/new_question_text.dart';
import 'package:screenshot/screenshot.dart';
import '../../../modules/level_api/services/problem_api_service.dart';
import '../../../shared/services/image_service.dart';
import '../../../shared/widgets/appbar_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/successful_popup.dart';
import '../../../shared/widgets/toase_message.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../controller/level_1_3_2_basic_controller.dart';
import '../widgets/basic_sample_popup.dart';

class LevelOneThreeTwoBasic extends StatefulWidget {
  final String problemCode;

  const LevelOneThreeTwoBasic({super.key, required this.problemCode});

  @override
  State<LevelOneThreeTwoBasic> createState() => _LevelOneThreeTwoBasicState();
}

class _LevelOneThreeTwoBasicState extends State<LevelOneThreeTwoBasic>
    with TickerProviderStateMixin {
  late final LevelOneThreeTwoBasicController controller;
  final ScreenshotController screenshotController = ScreenshotController();
  bool isSubmitted = false;
  bool isSubmitting = false;
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    controller = LevelOneThreeTwoBasicController(
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

      if (!isSubmitted) {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (!controller.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    final problem = controller.problemData;
    final options = problem["options"] as List;
    final images = problem["images"] as List? ?? [];
    final selected = problem["selectedValue"];
    final value = problem["value"];
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
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Column(
              children: [
                Screenshot(
                  controller: screenshotController,
                  child: Container(
                    height: screenHeight * 0.82,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          // height: screenHeight * 0.15,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                NewHeaderWidget(
                                  headerText: "기초학습활동",
                                  headerTextSize: screenWidth * 0.028,
                                  subTextSize: screenWidth * 0.018,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: NewQuestionTextWidget(
                                        questionText:
                                            "다음 <보기>의 숫자가 들어가기 알맞은 곳을 선택해 봅시다.",
                                        questionTextSize: screenWidth * 0.03,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: controller.showSample,
                                      icon: Icon(
                                        Icons.lightbulb,
                                        size: screenWidth * 0.04,
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
                        SizedBox(height: screenHeight * 0.18),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: screenHeight * 0.15,
                                width: screenWidth * 0.3,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.orangeAccent,
                                    width: 4,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "$value",
                                    style: const TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "<보기>",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GridView.count(
                          crossAxisCount: 5,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.75,
                          padding: const EdgeInsets.all(16),
                          children: List.generate(options.length, (i) {
                            final opt = options[i];
                            final image = images[i];
                            final isSelectable = opt == null;
                            final isTapped = selected == i;

                            return ElevatedButton(
                              onPressed:
                                  isSelectable
                                      ? () => controller.updateUserInput(
                                        selectedValue: i,
                                      )
                                      : null,
                              style: ElevatedButton.styleFrom(
                                disabledBackgroundColor: Colors.white,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(
                                    color: Colors.blueAccent,
                                    width: isTapped ? 4.0 : 1.0,
                                  ),
                                ),
                                padding: const EdgeInsets.all(5.0),
                                elevation: 5,
                              ),
                              child:
                                  opt != null
                                      ? Image.network(
                                        image,
                                        fit: BoxFit.contain,
                                      )
                                      : const Icon(
                                        Icons.question_mark_rounded,
                                        size: 50,
                                        color: Colors.blueAccent,
                                      ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: screenHeight * 0.02,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Row(
                      key: ValueKey<String>(
                        '${isSubmitted}_${controller.showCorrect}',
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
                            onPressed:
                                (isSubmitting || isSubmitted)
                                    ? null
                                    : saveSubmissionData,
                          ),

                        if (isSubmitted && isCorrectAnswer == false) ...[
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
                          child: BasicSamplePopup(
                            scaleAnimation: const AlwaysStoppedAnimation(1.0),
                            onClose: controller.closeSample,
                            desc: "💡 다음 보기의 숫자가 들어가기 알맞은 곳을 선택해봅시다.",
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
                              customMessage:
                                  controller.showCorrect
                                      ? "🎉 정답이에요!"
                                      : "틀렸어요...",
                              isEnd: isEnd,
                              closePopup: controller.closeSubmit,
                              onClose:
                                  controller.showCorrect
                                      ? () async => controller.onNextPressed()
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
      ),
    );
  }
}
