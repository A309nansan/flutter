import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/request_service.dart';

class LevelOneThreeTwoBasicController {
  final TickerProvider ticker;
  final VoidCallback onUpdate;

  LevelOneThreeTwoBasicController({
    required this.ticker,
    required this.onUpdate,
  });

  late DateTime _startTime;
  late Map<String, dynamic> originalProblem;
  late Map<String, dynamic> problemData;
  late bool showCorrect;
  late AnimationController popController;
  late AnimationController submitController;
  late Animation<double> popAnimation;
  late Animation<double> submitAnimation;

  bool showSubmitPopup = false;
  bool isShowSample = false;
  bool isInitialized = false;
  late String problemCode;
  DateTime? submissionTime;
  late int currentProblemNumber;
  late int totalProblemCount;

  Future<void> init(String problemCode) async {
    this.problemCode = problemCode;

    final response = await RequestService.post("/en/problem/make", data: {
      "problem_code": problemCode,
    });

    currentProblemNumber = response["current_problem_number"];
    totalProblemCount = response["total_problem_count"];

    _startTime = DateTime.now();
    originalProblem = response;

    final problem = response["problem"];
    final answer = response["answer"];

    problemData = {
      "value": problem["value"],
      "options": problem["options"],
      "images": problem["images"],
      "result": answer["value"],
      "correctController": AnimationController(
        vsync: ticker,
        duration: const Duration(milliseconds: 800),
      ),
      "wrongController": AnimationController(
        vsync: ticker,
        duration: const Duration(milliseconds: 500),
      ),
      "selectedValue": null,
    };

    showCorrect = false;

    popController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );
    submitController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );

    popAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: popController, curve: Curves.elasticOut),
    );
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

  void updateUserInput({int? selectedValue}) {
    if (selectedValue != null) {
      problemData["selectedValue"] = selectedValue;
    }

    final isCorrect = (problemData["selectedValue"] == problemData["result"]);

    final controllerKey = isCorrect ? "correctController" : "wrongController";
    final controller = problemData[controllerKey] as AnimationController;

    controller.reset();
    if (isCorrect) {
      controller.forward();
    } else {
      controller.forward(from: 0.5);
    }

    showCorrect = isCorrect;
    onUpdate();
  }

  void showSample() {
    isShowSample = true;
    popController.forward(from: 0.0);
    onUpdate();
  }

  void closeSample() {
    popController.reverse();
  }

  void closeSubmit() {
    submitController.reverse().then((_) {
      showSubmitPopup = false;
      onUpdate();
    });
  }

  void dispose() {
    (problemData["correctController"] as AnimationController).dispose();
    (problemData["wrongController"] as AnimationController).dispose();
    popController.dispose();
    submitController.dispose();
  }

  Map<String, dynamic> buildResultJson({
    required DateTime dateTime,
    required childId,
  }) {
    return {
      "child_id" : childId,
      "problem_code": problemCode,
      "date_time": dateTime.toIso8601String(),
      "solving_time": DateTime.now().difference(_startTime).inSeconds.round(),
      "is_corrected": showCorrect,
      "problem": originalProblem["problem"],
      "answer": originalProblem["answer"],
      "input": {
        "selected_value": problemData["selectedValue"],
      }
    };
  }

  void onNextPressed() {
    final nextCode = originalProblem["next_problem_code"] as String?;
    if (nextCode == null || nextCode.isEmpty) {
      print("📌 다음 문제가 없습니다.");
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
}