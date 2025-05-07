import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../../shared/provider/EnRiverPodProvider.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/request_service.dart';
import '../../../shared/services/secure_storage_service.dart';

class LevelOneFourTwoMainController {
  final TickerProvider ticker;
  final VoidCallback onUpdate;
  final WidgetRef ref;

  LevelOneFourTwoMainController({required this.ticker, required this.onUpdate, required this.ref,});

  late DateTime _startTime;
  late String problemCode;
  late Map<String, dynamic> originalProblem;
  late Map<String, dynamic> problemData;
  late AnimationController popController;
  late AnimationController submitController;
  late AnimationController correctController;
  late AnimationController wrongController;
  late Animation<double> popAnimation;
  late Animation<double> submitAnimation;

  bool isInitialized = false;
  bool isChecked = false;
  bool showCorrect = false;
  bool showSubmitPopup = false;
  bool isShowSample = false;
  DateTime? submissionTime;
  late int currentProblemNumber;
  late int totalProblemCount;
  late int childId;

  Future<void> init(String problemCode) async {
    this.problemCode = problemCode;
    childId = (await SecureStorageService.getChildId())!;


    final saved = await EnProblemService.loadProblemResults(problemCode, childId);
    ref.read(problemProgressProvider.notifier).setFromStorage(saved);

    final progress = ref.read(problemProgressProvider);
    debugPrint("📦 불러온 문제 기록: $progress");

    EnProblemService.saveContinueProblem(problemCode, childId);

    final response = await RequestService.post(
      "/en/problem/make",
      data: {"problem_code": problemCode},
    );

    currentProblemNumber = response["current_problem_number"];
    totalProblemCount = response["total_problem_count"];

    _startTime = DateTime.now();
    originalProblem = response;
    final problem = response["problem"];
    final answer = response["answer"];

    problemData = {
      "left": problem["left"],
      "right": problem["right"],
      "value": answer["value"],
      "leftKey": GlobalKey<HandwritingRecognitionZoneState>(),
      "rightKey": GlobalKey<HandwritingRecognitionZoneState>(),
      "valueKey": GlobalKey<HandwritingRecognitionZoneState>(),
      "resultKey": GlobalKey<HandwritingRecognitionZoneState>(),
      "inputLeft": null,
      "inputRight": null,
      "inputValue": null,
      "inputResult": null,
    };

    correctController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 800),
    );
    wrongController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 500),
    );
    popController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );
    submitController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );

    popAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: popController, curve: Curves.elasticOut));
    submitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: submitController, curve: Curves.elasticOut),
    );

    popController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        isShowSample = false;
        onUpdate();
      }
    });

    isInitialized = true;
    onUpdate();
  }

  void updateUserInput({int? left, int? right, int? value, int? result}) {
    if (left != null) problemData["inputLeft"] = left;
    if (right != null) problemData["inputRight"] = right;
    if (value != null) problemData["inputValue"] = value;
    if (result != null) problemData["inputResult"] = result;

    final isCorrect =
        problemData["inputLeft"] == problemData["left"] &&
        problemData["inputRight"] == problemData["right"] &&
        problemData["inputValue"] == problemData["value"] &&
        problemData["inputResult"] == problemData["right"];

    if (isCorrect) {
      correctController.forward(from: 0);
    } else {
      wrongController.forward(from: 0.5);
    }

    showCorrect = isCorrect;
    onUpdate();
  }

  void clearSingleField(String field) {
    final key =
        problemData["${field}Key"]
            as GlobalKey<HandwritingRecognitionZoneState>;
    key.currentState?.clear();
    problemData["input${capitalize(field)}"] = null;
    isChecked = false;
    showCorrect = false;
    onUpdate();
  }

  void clearAnswer() {
    for (var field in ['left', 'right', 'value', 'result']) {
      clearSingleField(field);
    }
  }

  void showSample() {
    isShowSample = true;
    popController.forward(from: 0);
    onUpdate();
  }

  void closeSample() => popController.reverse();

  void showSubmit() {
    showSubmitPopup = true;
    submitController.forward(from: 0);
    onUpdate();
  }

  void closeSubmit() {
    submitController.reverse().then((_) {
      showSubmitPopup = false;
      onUpdate();
    });
  }

  Map<String, dynamic> buildResultJson({
    required DateTime dateTime,
    required dynamic childId,
  }) {
    return {
      "child_id": childId,
      "problem_code": problemCode,
      "date_time": dateTime.toIso8601String(),
      "solving_time": DateTime.now().difference(_startTime).inSeconds,
      "is_corrected": showCorrect,
      "problem": originalProblem["problem"],
      "answer": originalProblem["answer"],
      "input": {
        "input_left": problemData["inputLeft"],
        "input_right": problemData["inputRight"],
        "input_value": problemData["inputValue"],
        "input_result": problemData["inputResult"],
      },
    };
  }

  void onNextPressed() async {
    final nextCode = originalProblem["next_problem_code"] as String?;
    if (nextCode == null || nextCode.isEmpty) {
      debugPrint("📌 다음 문제가 없습니다.");
      // 최종 결과 저장 (SharedPreferences에 누적 기록 저장)
      final progress = ref.read(problemProgressProvider);
      await EnProblemService.saveProblemResults(
        progress,
        problemCode,
        childId,
      );

      // 이어풀기 데이터 제거
      await EnProblemService.clearChapterProblem(childId, problemCode);
      Modular.to.pop();
      return;
    }

    try {
      final route = EnProblemService().getLevelPath(nextCode);
      Modular.to.pushReplacementNamed(route, arguments: nextCode);
    } catch (e) {
      debugPrint("⚠️ 경로 생성 중 오류: $e");
    }
  }

  void dispose() {
    correctController.dispose();
    wrongController.dispose();
    popController.dispose();
    submitController.dispose();
  }

  String capitalize(String text) => text[0].toUpperCase() + text.substring(1);
}
