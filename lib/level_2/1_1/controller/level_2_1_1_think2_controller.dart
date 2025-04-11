import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/request_service.dart';

class LevelTwoOneOneThink2Controller {
  final TickerProvider ticker;
  final VoidCallback onUpdate;

  LevelTwoOneOneThink2Controller({
    required this.ticker,
    required this.onUpdate,
  });

  late DateTime _startTime;
  late Map<String, dynamic> originalProblem;
  late List<Map<String, dynamic>> problemData;

  late List<AnimationController> cardControllers;
  late List<bool> cardSelected;
  late List<bool> cardCorrect;

  late AnimationController submitController;
  late Animation<double> submitAnimation;

  bool showSubmitPopup = false;
  bool isInitialized = false;
  bool isCorrect = false;
  late String problemCode;
  DateTime? submissionTime;
  int correctTarget = 0;
  late int currentProblemNumber;
  late int totalProblemCount;

  Future<void> init(String code) async {
    problemCode = code;

    final res = await RequestService.post(
      "/en/problem/make",
      data: {"problem_code": problemCode},
    );

    currentProblemNumber = res["current_problem_number"];
    totalProblemCount = res["total_problem_count"];

    _startTime = DateTime.now();
    originalProblem = res;

    final problems = res["problem"]["candidates"];
    final answers = res["answer"]["values"];
    correctTarget = answers.where((e) => e["value"] == 10).length;

    problemData = List.generate(problems.length, (i) {
      final p = problems[i];
      final a = answers[i];
      return {
        "value": p["value"],
        "images": p["images"] ?? [],
        "result": a["value"],
        "isSelected": false,
        "isCorrect": false,
      };
    });

    cardControllers = List.generate(
      problems.length,
      (_) => AnimationController(
        vsync: ticker,
        duration: const Duration(milliseconds: 800),
      ),
    );

    cardSelected = List.generate(problems.length, (_) => false);
    cardCorrect = List.generate(problems.length, (_) => false);

    submitController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );
    submitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: submitController, curve: Curves.elasticOut),
    );

    isInitialized = true;
    onUpdate();
  }

  void onCardPressed(int index) {
    cardSelected[index] = !cardSelected[index];
    final isCorrect = problemData[index]["value"] == 10;

    cardCorrect[index] = cardSelected[index] && isCorrect;
    problemData[index]["isSelected"] = cardSelected[index];
    problemData[index]["isCorrect"] = cardCorrect[index];

    onUpdate();
  }

  void showSubmit() {
    showSubmitPopup = true;
    submitController.forward(from: 0.0);
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
    required childId,
  }) {
    final correct = cardCorrect.where((e) => e).length == correctTarget;

    return {
      "child_id": childId,
      "problem_code": problemCode,
      "date_time": dateTime.toIso8601String(),
      "solving_time": DateTime.now().difference(_startTime).inSeconds,
      "is_corrected": correct,
      "problem": originalProblem["problem"],
      "answer": originalProblem["answer"],
      "input": {
        "values": List.generate(
          problemData.length,
          (i) => {
            "is_selected": problemData[i]["isSelected"],
            "is_correct": problemData[i]["isCorrect"],
          },
        ),
      },
    };
  }

  void onNextPressed() {
    final nextCode = originalProblem["next_problem_code"] as String?;
    if (nextCode == null || nextCode.isEmpty) {
      debugPrint("📌 다음 문제가 없습니다.");
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
    for (var controller in cardControllers) {
      controller.dispose();
    }
    submitController.dispose();
  }
}
