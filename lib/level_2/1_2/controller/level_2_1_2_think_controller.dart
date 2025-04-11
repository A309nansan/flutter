import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/request_service.dart';
import '../../1_2/widgets/drag_group_widget.dart';

class LevelTwoOneTwoThinkController {
  final TickerProvider ticker;
  final VoidCallback onUpdate;

  LevelTwoOneTwoThinkController({required this.ticker, required this.onUpdate});

  late DateTime _startTime;
  late String problemCode;
  late Map<String, dynamic> originalProblem;
  late Map<String, dynamic> problemData;

  late AnimationController popController;
  late AnimationController submitController;
  late Animation<double> popAnimation;
  late Animation<double> submitAnimation;

  bool isShowSample = false;
  bool showSubmitPopup = false;
  bool isInitialized = false;
  DateTime? submissionTime;
  late int currentProblemNumber;
  late int totalProblemCount;

  Future<void> init(String problemCode) async {
    this.problemCode = problemCode;

    final response = await RequestService.post(
      "/en/problem/make",
      data: {"problem_code": problemCode},
    );

    currentProblemNumber = response["current_problem_number"];
    totalProblemCount = response["total_problem_count"];

    _startTime = DateTime.now();
    originalProblem = response;

    final problem = response["problem"];

    problemData = {
      "value": problem["value"],
      "img": problem["img"],
      "number_text": problem["number_text"],
      "tenKey": GlobalKey<HandwritingRecognitionZoneState>(),
      "oneKey": GlobalKey<HandwritingRecognitionZoneState>(),
      "gridKey": GlobalKey<GridDragGroupWidgetState>(),
      "selectedCount": 0,
      "isCorrect": false,
      "isChecked": false,
    };

    popController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );
    popAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: popController, curve: Curves.elasticOut));

    submitController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
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

  void updateCorrectStatus({
    required bool isWritingCorrect,
    required bool isDragCorrect,
  }) {
    problemData["isCorrect"] = isWritingCorrect && isDragCorrect;
    onUpdate();
  }

  Duration getElapsedTime() {
    return DateTime.now().difference(_startTime);
  }

  Map<String, dynamic> buildResultJson({
    required DateTime dateTime,
    required dynamic childId,
  }) {
    final problem = originalProblem["problem"];
    final ten = problemData["tenKey"].currentState?.recognizedText ?? '';
    final one = problemData["oneKey"].currentState?.recognizedText ?? '';
    final combined = "$ten$one";

    return {
      "child_id": childId,
      "problem_code": problemCode,
      "date_time": dateTime.toIso8601String(),
      "solving_time": getElapsedTime().inSeconds,
      "is_corrected": problemData["isCorrect"],
      "problem": originalProblem["problem"],
      "answer": originalProblem["answer"],
      "input": {
        "recognized_text": combined,
        "selected_count": problemData["selectedCount"],
        "is_writing_correct": combined == problem["value"].toString(),
        "is_drag_correct": problemData["selectedCount"] == 10,
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
    popController.dispose();
    submitController.dispose();
  }
}
