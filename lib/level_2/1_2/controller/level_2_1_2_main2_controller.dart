import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/request_service.dart';

class LevelTwoOneTwoMain2Controller {
  final TickerProvider ticker;
  final VoidCallback onUpdate;

  LevelTwoOneTwoMain2Controller({required this.ticker, required this.onUpdate});

  late String problemCode;
  late DateTime _startTime;
  late Map<String, dynamic> originalProblem;
  late Map<String, dynamic> problemData;
  DateTime? submissionTime;
  late int currentProblemNumber;
  late int totalProblemCount;

  bool isInitialized = false;
  bool isShowSample = false;
  bool showSubmitPopup = false;

  bool lCardSelected = false;
  bool rCardSelected = false;
  bool lCardCorrect = false;
  bool rCardCorrect = false;
  bool lCardWrong = false;
  bool rCardWrong = false;

  bool get isInputComplete => lCardSelected || rCardSelected;
  bool get isCorrect => lCardCorrect || rCardCorrect;

  late AnimationController lCardController;
  late AnimationController rCardController;
  late AnimationController popController;
  late AnimationController submitController;
  late Animation<double> popAnimation;
  late Animation<double> submitAnimation;

  Future<void> init(String problemCode) async {
    this.problemCode = problemCode;

    final response = await RequestService.post(
      "/en/problem/make",
      data: {"problem_code": problemCode},
    );

    print(response);
    currentProblemNumber = response["current_problem_number"];
    totalProblemCount = response["total_problem_count"];

    _startTime = DateTime.now();
    originalProblem = response;

    final problem = response["problem"];
    final answer = response["answer"];

    problemData = {
      "value": problem["value"],
      "left": problem["left"],
      "right": problem["right"],
      "answer": answer["value"],
    };

    _initializeAnimations();
    isInitialized = true;
    onUpdate();
  }

  void _initializeAnimations() {
    lCardController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 800),
    );
    rCardController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 800),
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
  }

  void onCardPressed(bool isLeft) {
    _resetCardState();
    _checkAnswer(isLeft);
    onUpdate();
  }

  void _resetCardState() {
    lCardSelected = false;
    rCardSelected = false;
    lCardCorrect = false;
    rCardCorrect = false;
    lCardWrong = false;
    rCardWrong = false;
  }

  void _checkAnswer(bool isLeft) {
    final selectedValue = isLeft ? problemData["left"] : problemData["right"];
    final correctAnswer = problemData["answer"];

    if (selectedValue == correctAnswer) {
      if (isLeft) {
        lCardSelected = true;
        lCardCorrect = true;
        lCardController.forward();
      } else {
        rCardSelected = true;
        rCardCorrect = true;
        rCardController.forward();
      }
    } else {
      if (isLeft) {
        lCardSelected = true;
        lCardWrong = true;
      } else {
        rCardSelected = true;
        rCardWrong = true;
      }
    }
  }

  void showSample() {
    isShowSample = true;
    popController.forward(from: 0.0);
    onUpdate();
  }

  void closeSample() {
    popController.reverse();
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

  Duration getElapsedTime() {
    return DateTime.now().difference(_startTime);
  }

  Map<String, dynamic> buildResultJson({
    required DateTime dateTime,
    required dynamic childId,
  }) {
    return {
      "child_id": childId,
      "problem_code": problemCode,
      "date_time": dateTime.toIso8601String(),
      "solving_time": getElapsedTime().inSeconds,
      "is_corrected": isCorrect,
      "problem": originalProblem["problem"],
      "answer": originalProblem["answer"],
      "input": {
        "selected_value":
            lCardSelected ? problemData["left"] : problemData["right"],
      },
    };
  }

  void onNextPressed() {
    final nextCode = originalProblem["next_problem_code"] as String?;
    if (nextCode == null || nextCode.isEmpty) {
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
    lCardController.dispose();
    rCardController.dispose();
    popController.dispose();
    submitController.dispose();
  }
}
