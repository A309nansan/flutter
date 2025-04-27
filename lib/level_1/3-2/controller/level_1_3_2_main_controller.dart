import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/request_service.dart';
import '../../../shared/services/secure_storage_service.dart';

class LevelOneThreeTwoMainController {
  final TickerProvider ticker;
  final VoidCallback onUpdate;

  LevelOneThreeTwoMainController({required this.ticker, required this.onUpdate});

  late DateTime _startTime;
  late String problemCode;
  late Map<String, dynamic> originalProblem;
  late Map<String, dynamic> problemData;

  late AnimationController popController;
  late AnimationController submitController;
  late Animation<double> popAnimation;
  late Animation<double> submitAnimation;

  bool isInitialized = false;
  bool isShowSample = false;
  bool showSubmitPopup = false;
  bool isCorrect = false;
  DateTime? submissionTime;
  late int currentProblemNumber;
  late int totalProblemCount;
  late int childId;

  Future<void> init(String code) async {
    problemCode = code;
    childId = (await SecureStorageService.getChildId())!;
    EnProblemService.saveContinueProblem(problemCode, childId);

    final response = await RequestService.post("/en/problem/make", data: {
      "problem_code": code,
    });

    currentProblemNumber = response["current_problem_number"];
    totalProblemCount = response["total_problem_count"];

    _startTime = DateTime.now();
    originalProblem = response;
    final p = response["problem"];
    final a = response["answer"];

    problemData = {
      "value": p["value"],
      "options": p["options"],
      "images": p["images"],
      "type": p["type"],
      "result": a["value"],
      "keys": List.generate(3, (_) => GlobalKey<HandwritingRecognitionZoneState>()),
      "selectedValue": null,
      "firstInput": null,
      "secondInput": null,
      "thirdInput": null,
    };

    popController = AnimationController(vsync: ticker, duration: const Duration(milliseconds: 400));
    submitController = AnimationController(vsync: ticker, duration: const Duration(milliseconds: 400));

    popAnimation = CurvedAnimation(parent: popController, curve: Curves.elasticOut);
    submitAnimation = CurvedAnimation(parent: submitController, curve: Curves.elasticOut);

    isInitialized = true;
    onUpdate();
  }

  void updateUserInput({int? selectedValue, int? firstInput, int? secondInput, int? thirdInput}) {
    if (selectedValue != null) problemData["selectedValue"] = selectedValue;
    if (firstInput != null) problemData["firstInput"] = firstInput;
    if (secondInput != null) problemData["secondInput"] = secondInput;
    if (thirdInput != null) problemData["thirdInput"] = thirdInput;
    onUpdate();
  }

  void evaluateProblem() {
    final keys = problemData["keys"] as List<GlobalKey<HandwritingRecognitionZoneState>>;
    final selected = problemData["selectedValue"];

    final inputs = keys.map((key) => int.tryParse(key.currentState?.recognizedText ?? '')).toList();

    updateUserInput(firstInput: inputs[0], secondInput: inputs[1], thirdInput: inputs[2]);

    final input = selected != null ? inputs[selected] : null;
    final correct = problemData["result"];
    isCorrect = input == correct;

    onUpdate();
  }

  Map<String, dynamic> buildResultJson({required DateTime dateTime, required int childId}) {
    return {
      "child_id": childId,
      "problem_code": problemCode,
      "date_time": dateTime.toIso8601String(),
      "solving_time": DateTime.now().difference(_startTime).inSeconds,
      "is_corrected": isCorrect,
      "problem": originalProblem["problem"],
      "answer": originalProblem["answer"],
      "input": {
        "selected_value": problemData["selectedValue"],
        "first_input": problemData["firstInput"],
        "second_input": problemData["secondInput"],
        "third_input": problemData["thirdInput"],
      }
    };
  }

  void showSample() {
    isShowSample = true;
    popController.forward(from: 0.0);
    onUpdate();
  }

  void closeSample() {
    popController.reverse().then((_) {
      isShowSample = false;
      onUpdate();
    });
  }

  void closeSubmit() {
    submitController.reverse().then((_) {
      showSubmitPopup = false;
      onUpdate();
    });
  }

  void clearSingleField(int index) {
    final key = problemData["keys"][index] as GlobalKey<HandwritingRecognitionZoneState>;
    key.currentState?.clear();

    if (index == 0) problemData["firstInput"] = null;
    if (index == 1) problemData["secondInput"] = null;
    if (index == 2) problemData["thirdInput"] = null;

    isCorrect = false;
    onUpdate();
  }

  void onNextPressed() {
    final nextCode = originalProblem["next_problem_code"] as String?;
    if (nextCode == null || nextCode.isEmpty) {
      print("📌 다음 문제가 없습니다.");
      EnProblemService.clearChapterProblem(childId, problemCode);
      Modular.to.pop();
      return;
    }

    try {
      final route = EnProblemService().getLevelPath(nextCode);
      Modular.to.pushReplacementNamed(route, arguments: nextCode);
    } catch (e) {
      print("⚠️ 경로 생성 중 오류: $e");
    }
  }

  void dispose() {
    popController.dispose();
    submitController.dispose();
  }
}