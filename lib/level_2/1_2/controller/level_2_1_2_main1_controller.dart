import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/request_service.dart';
import '../models/pattern_type.dart';

class LevelTwoOneTwoMain1Controller {
  final TickerProvider ticker;
  final VoidCallback onUpdate;

  LevelTwoOneTwoMain1Controller({required this.ticker, required this.onUpdate});

  late DateTime _startTime;
  late String problemCode;
  late Map<String, dynamic> originalProblem;
  late Map<String, dynamic> problemData;

  late final AnimationController lCardController;
  late final AnimationController rCardController;

  bool lCardSelected = false;
  bool rCardSelected = false;
  bool lCardCorrect = false;
  bool rCardCorrect = false;
  bool lCardWrong = false;
  bool rCardWrong = false;

  PatternType selectedPattern = PatternType.heart;
  int filledCount = 0;
  bool isPatternCorrect = false;
  late int currentProblemNumber;
  late int totalProblemCount;

  late final AnimationController popController;
  late final AnimationController submitController;
  late final AnimationController allCorrectPopController;

  late final Animation<double> popAnimation;
  late final Animation<double> submitAnimation;
  late final Animation<double> allCorrectPopAnimation;

  bool isInitialized = false;
  bool isShowSample = false;
  bool showSubmitPopup = false;
  bool showAllCorrectOverlay = false;
  DateTime? submissionTime;

  Future<void> init(String code) async {
    problemCode = code;
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
      "value": problem["value"],
      "left": problem["left"],
      "right": problem["right"],
      "answer": answer["value"],
      "firstInput": null,
      "secondInput": null,
      "isCorrect": false,
    };

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
    allCorrectPopController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );

    popAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: popController, curve: Curves.elasticOut));
    submitAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: submitController, curve: Curves.elasticOut),
    );
    allCorrectPopAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: allCorrectPopController,
        curve: Curves.elasticOut,
      ),
    );

    allCorrectPopController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (allCorrectPopController.status == AnimationStatus.completed) {
            allCorrectPopController.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        showAllCorrectOverlay = false;
        onUpdate();
      }
    });

    isInitialized = true;
    onUpdate();
  }

  void onCardPressed(bool isLeft) {
    final selectedValue = isLeft ? problemData["left"] : problemData["right"];
    final correctValue = problemData["answer"];

    problemData["firstInput"] = selectedValue;

    lCardSelected = isLeft;
    rCardSelected = !isLeft;

    lCardCorrect = rCardCorrect = false;
    lCardWrong = rCardWrong = false;

    if (selectedValue == correctValue) {
      if (isLeft) {
        lCardCorrect = true;
        lCardController.forward(from: 0.0);
      } else {
        rCardCorrect = true;
        rCardController.forward(from: 0.0);
      }
    } else {
      if (isLeft) {
        lCardWrong = true;
        Future.delayed(const Duration(seconds: 1), () {
          lCardWrong = false;
          onUpdate();
        });
      } else {
        rCardWrong = true;
        Future.delayed(const Duration(seconds: 1), () {
          rCardWrong = false;
          onUpdate();
        });
      }
    }

    _updateCorrectState();
  }

  void updatePatternCorrect(bool isCorrect) {
    isPatternCorrect = isCorrect;
    problemData["secondInput"] = filledCount;
    _updateCorrectState();

    if (problemData["isCorrect"]) {
      showAllCorrectOverlay = true;
      allCorrectPopController.forward(from: 0.0);
    }
  }

  void _updateCorrectState() {
    final selectedValue =
        lCardSelected
            ? problemData["left"]
            : rCardSelected
            ? problemData["right"]
            : null;
    final isCardCorrect = selectedValue == problemData["answer"];

    problemData["isCorrect"] = isCardCorrect && isPatternCorrect;
    onUpdate();
  }

  bool get isInputComplete =>
      problemData["firstInput"] != null && problemData["secondInput"] != null;

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

  Map<String, dynamic> buildResultJson({
    required DateTime dateTime,
    required dynamic childId,
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
    lCardController.dispose();
    rCardController.dispose();
    popController.dispose();
    submitController.dispose();
    allCorrectPopController.dispose();
  }
}
