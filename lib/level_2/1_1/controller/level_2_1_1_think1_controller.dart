import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/request_service.dart';
import '../models/problem.dart';
import '../widgets/dot_connector.dart';

class LevelTwoOneOneThink1Controller {
  final TickerProvider ticker;
  final VoidCallback onUpdate;
  final GlobalKey<DotConnectorState> dotConnectorKey;

  LevelTwoOneOneThink1Controller({
    required this.ticker,
    required this.onUpdate,
    required this.dotConnectorKey,
  });

  late final DateTime _startTime;
  late final AnimationController wrongController;
  late final AnimationController popController;
  late final AnimationController submitController;

  late final Animation<double> popAnimation;
  late final Animation<double> submitAnimation;

  late Problem originalProblem;
  late List<ProblemLine> problemLines;

  bool showWrongAnimation = false;
  bool showAllCorrectOverlay = false;
  bool isAllCorrect = false;
  bool showSubmitPopup = false;
  bool isInitialized = false;
  late String problemCode;
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

    originalProblem = Problem.fromJson(response);
    problemLines = originalProblem.problem.lines;
    _startTime = DateTime.now();

    wrongController = AnimationController(vsync: ticker);
    submitController = _buildAnimationController();
    popController = _buildAnimationController();

    submitAnimation = _buildAnimation(submitController);
    popAnimation = _buildAnimation(popController);

    popController.addStatusListener(_onPopStatusChange);

    isInitialized = true;
    onUpdate();
  }

  AnimationController _buildAnimationController() {
    return AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );
  }

  Animation<double> _buildAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
  }

  void _onPopStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(seconds: 1), () {
        if (popController.status == AnimationStatus.completed) {
          popController.reverse();
        }
      });
    } else if (status == AnimationStatus.dismissed) {
      showAllCorrectOverlay = false;
      onUpdate();
    }
  }

  void updateMatch(int index, bool matched) {
    final line = problemLines[index];
    line.userMatched = matched;
    line.isCorrect = matched;
    onUpdate();
  }

  void onReset() {
    dotConnectorKey.currentState?.resetAll();
    for (final line in problemLines) {
      line.userMatched = null;
      line.isCorrect = false;
    }
    showAllCorrectOverlay = false;
    isAllCorrect = false;
    onUpdate();
  }

  void triggerWrongAnimation() {
    showWrongAnimation = true;
    onUpdate();
    Future.delayed(const Duration(seconds: 1), () {
      showWrongAnimation = false;
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
    final input = {
      for (int i = 0; i < problemLines.length; i++)
        'line${i + 1}': problemLines[i].toJson(),
    };

    return {
      "child_id": childId,
      "problem_code": problemCode,
      "date_time": dateTime.toIso8601String(),
      "solving_time": getElapsedTime().inSeconds,
      "is_corrected": problemLines.every((l) => l.isCorrect),
      "problem": originalProblem.problem.toJson(),
      "answer": originalProblem.answer,
      "input": input,
    };
  }

  Duration getElapsedTime() => DateTime.now().difference(_startTime);

  void onNextPressed() {
    final nextCode = originalProblem.nextProblemCode;
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
    wrongController.dispose();
    popController.dispose();
    submitController.dispose();
  }
}
