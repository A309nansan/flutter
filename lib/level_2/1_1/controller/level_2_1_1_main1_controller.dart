import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/request_service.dart';

class LevelTwoOneOneMain1Controller {
  final TickerProvider ticker;
  final VoidCallback onUpdate;

  LevelTwoOneOneMain1Controller({required this.ticker, required this.onUpdate});

  late DateTime _startTime;
  late String problemCode;
  late Map<String, dynamic> originalProblem;
  late Map<String, dynamic> problemData;

  late AnimationController submitController;
  late Animation<double> submitAnimation;
  late AnimationController popController;
  late Animation<double> popAnimation;

  bool isShowSample = false;
  bool showSubmitPopup = false;
  bool isInitialized = false;
  DateTime? submissionTime;
  late int currentProblemNumber;
  late int totalProblemCount;

  Future<void> init(String code) async {
    problemCode = code;

    final response = await RequestService.post(
      "/en/problem/make",
      data: {"problem_code": code},
    );

    currentProblemNumber = response["current_problem_number"];
    totalProblemCount = response["total_problem_count"];

    _startTime = DateTime.now();
    originalProblem = response;

    final problem = response["problem"];

    problemData = {
      "first": problem["first"],
      "second": problem["second"],
      "firstKey": GlobalKey<HandwritingRecognitionZoneState>(),
      "secondKey": GlobalKey<HandwritingRecognitionZoneState>(),
      "firstInput": null,
      "secondInput": null,
      "isCorrect": false,
    };

    submitController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );
    submitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: submitController, curve: Curves.elasticOut),
    );

    popController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );
    popAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: popController, curve: Curves.elasticOut));

    isInitialized = true;
    onUpdate();
  }

  void onRecognitionComplete() {
    final firstText =
        problemData["firstKey"].currentState?.recognizedText ?? '';
    final secondText =
        problemData["secondKey"].currentState?.recognizedText ?? '';

    final firstCorrect = firstText == problemData["first"].toString();
    final secondCorrect = secondText == problemData["second"].toString();
    final isCorrect = firstCorrect && secondCorrect;

    problemData["firstInput"] = firstText;
    problemData["secondInput"] = secondText;
    problemData["isCorrect"] = isCorrect;

    onUpdate();
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

  void clearHandwritingFields() {
    problemData["firstKey"].currentState?.clear();
    problemData["secondKey"].currentState?.clear();
  }

  Map<String, dynamic> buildResultJson({
    required DateTime dateTime,
    required childId,
  }) {
    return {
      "child_id": childId,
      "problem_code": problemCode,
      "date_time": dateTime.toIso8601String(),
      "solving_time": DateTime.now().difference(_startTime).inSeconds,
      "is_corrected": problemData["isCorrect"],
      "problem": originalProblem["problem"],
      "answer": originalProblem["answer"],
      "input": {
        "first_input": problemData["firstInput"],
        "second_input": problemData["secondInput"],
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
    submitController.dispose();
    popController.dispose();
  }
}
