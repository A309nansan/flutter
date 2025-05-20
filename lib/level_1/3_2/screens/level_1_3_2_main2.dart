import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../../../modules/level_api/services/problem_api_service.dart';
import '../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../../shared/provider/en_riverpod_provider.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/image_service.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/appbar_widget.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/en_problem_splash_screen.dart';
import '../../../shared/widgets/en_progress_bar_widget.dart';
import '../../../shared/widgets/en_result_popup.dart';
import '../../../shared/widgets/new_header_widget.dart';
import '../../../shared/widgets/new_question_text.dart';
import '../../../shared/widgets/successful_popup.dart';
import '../../../shared/widgets/toase_message.dart';
import '../controller/level_1_3_2_main_controller.dart';
import '../widgets/main_sample_popup.dart';

class LevelOneThreeTwoMain2 extends ConsumerStatefulWidget {
  final String problemCode;

  const LevelOneThreeTwoMain2({super.key, required this.problemCode});

  @override
  ConsumerState<LevelOneThreeTwoMain2> createState() => _LevelOneThreeTwoMain2State();
}

class _LevelOneThreeTwoMain2State extends ConsumerState<LevelOneThreeTwoMain2>
    with TickerProviderStateMixin {
  late final LevelOneThreeTwoMainController controller;
  final ScreenshotController screenshotController = ScreenshotController();
  bool isEvaluated = false;
  bool isSubmitted = false;
  bool isSubmitting = false;
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    controller = LevelOneThreeTwoMainController(
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
      ToastMessage.show("이미 제출했어요!");
      return;
    }

    final keys =
        controller.problemData["keys"]
            as List<GlobalKey<HandwritingRecognitionZoneState>>;
    for (final zoneKey in keys) {
      if (zoneKey.currentState != null) {
        await zoneKey.currentState!.recognize();
      }
    }

    controller.evaluateProblem();
    setState(() => isEvaluated = true);

    setState(() => controller.showSubmitPopup = true);
    controller.submitController.forward();

    Future.delayed(Duration.zero, () async {
      await submitActivity(context);
    });
  }

  Future<void> saveSubmissionData() async {
    if (isSubmitting) return;

    final keys =
        controller.problemData["keys"]
            as List<GlobalKey<HandwritingRecognitionZoneState>>;
    for (final zoneKey in keys) {
      if (zoneKey.currentState != null) {
        await zoneKey.currentState!.recognize();
      }
    }

    controller.evaluateProblem();
    try {
      setState(() {
        isSubmitting = true;
        controller.showSubmitPopup = true;
        isCorrectAnswer = controller.isCorrect;
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

        ref.read(problemProgressProvider.notifier).record(
          controller.problemCode,
          controller.isCorrect,
        );

        await EnProblemService.saveProblemResults(
          ref.read(problemProgressProvider),
          controller.problemCode,
          controller.childId,
        );

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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
      return EnProblemSplashScreen();
    }

    final problem = controller.problemData;
    final options = problem["options"];
    final selected = problem["selectedValue"];
    final value = problem["value"];
    final type = problem["type"];
    final object = problem["object"];
    final keys = problem["keys"];
    final nextCode = controller.originalProblem["next_problem_code"] as String?;
    final isEnd = nextCode == null || nextCode.isEmpty;
    debugPrint(problem.toString());

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: screenHeight * 0.14,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                NewHeaderWidget(
                                  headerText: "주요학습활동",
                                  headerTextSize: screenWidth * 0.028,
                                  subTextSize: screenWidth * 0.018,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: NewQuestionTextWidget(
                                        questionText: "물체의 수를 세고 □ 안에 알맞은 숫자를 쓰고, 선택해 보세요.",
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 40,
                          ),
                          child: Text(
                            "물체의 수를 세고, □ 안에 알맞은 숫자를 써 봅시다. "
                            "$value보다 ${type == 0 ? '1 큰 수' : '1 작은 수'}에 선택하세요.",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 100,
                          ),
                          child: GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.4,
                            children: List.generate(options.length, (i) {
                              final opt = options[i];
                              final image = 'assets/images/number/$object/${options[i]}.png';
                              final key = keys[i];
                              final isTapped = selected == i;

                              return Column(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            () => controller.updateUserInput(
                                              selectedValue: i,
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            side: BorderSide(
                                              color: Colors.blueAccent,
                                              width: isTapped ? 5 : 1.5,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(10.0),
                                          elevation: 5,
                                        ),
                                        child:
                                            opt != null
                                                ? Image.asset(
                                                  image,
                                                  fit: BoxFit.contain,
                                                )
                                                : const Icon(
                                                  Icons.question_mark_rounded,
                                                  size: 50,
                                                ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Expanded(
                                    flex: 3,
                                    child: Stack(
                                      children: [
                                        HandwritingRecognitionZone(
                                          key: key,
                                          width: screenWidth * 0.3,
                                          height: double.infinity,
                                        ),
                                        Positioned(
                                          right: -5,
                                          top: -5,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            tooltip: "이 칸 초기화",
                                            onPressed:
                                                () => controller
                                                    .clearSingleField(i),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
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
                            '${isSubmitted}_${controller.isCorrect}',
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
                                onPressed: isEnd ?
                                    () => controller.showResult() : () => controller.onNextPressed(),
                              ),
                            ],

                            if (isSubmitted && isCorrectAnswer == true)
                              ButtonWidget(
                                height: screenHeight * 0.035,
                                width: screenWidth * 0.18,
                                buttonText: isEnd ? "학습종료" : "다음문제",
                                fontSize: screenWidth * 0.02,
                                borderRadius: 10,
                                onPressed: isEnd ?
                                    () => controller.showResult() : () => controller.onNextPressed(),
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
              child: Center(
                child: GestureDetector(
                  onTap: controller.closeSample,
                  child: FadeTransition(
                    opacity: controller.popAnimation,
                    child: Container(
                      color: Colors.black54,
                      child: ScaleTransition(
                        scale: controller.popAnimation,
                        child: MainSamplePopup(
                          scaleAnimation: const AlwaysStoppedAnimation(1.0),
                          onClose: controller.closeSample,
                          desc:
                              "\u{1F4A1} 물체의 수를 세고 (  ) 안에 알맞은 숫자를 쓰고, \u25CB표해 보세요.",
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
                            isCorrect: controller.isCorrect,
                            customMessage:
                                controller.isCorrect ? "🎉 정답이에요!" : "틀렸어요...",
                            isEnd: isEnd,
                            closePopup: controller.closeSubmit,
                            onClose:
                                controller.isCorrect
                                    ? () async => controller.onNextPressed()
                                    : null,
                            result: controller.getResult(),
                            end: () async => controller.onNextPressed()
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if(controller.isShowResult)
            Positioned.fill(
              child: Stack(
                children: [
                  Container(color: Colors.black54),
                  Center(
                    child: FadeTransition(
                      opacity: controller.resultAnimation,
                      child: ScaleTransition(
                        scale: controller.resultAnimation,
                        child: Material(
                          type: MaterialType.transparency,
                          child: EnResultPopup(
                              scaleAnimation: const AlwaysStoppedAnimation(1.0),
                              result: controller.getResult(),
                              end: () async => controller.end()
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
