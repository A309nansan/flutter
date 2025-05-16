import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/provider/en_riverpod_provider.dart';
import '../../../shared/services/en_problem_service.dart';
import '../../../shared/services/request_service.dart';
import '../../../shared/services/secure_storage_service.dart';

class LevelOneThreeTwoBasicController {
  final TickerProvider ticker;
  final VoidCallback onUpdate;
  final WidgetRef ref;

  LevelOneThreeTwoBasicController({
    required this.ticker,
    required this.onUpdate,
    required this.ref,
  });

  late DateTime _startTime;
  late Map<String, dynamic> originalProblem;
  late Map<String, dynamic> problemData;
  late bool showCorrect;
  late AnimationController popController;
  late AnimationController submitController;
  late AnimationController resultController;
  late Animation<double> popAnimation;
  late Animation<double> submitAnimation;
  late Animation<double> resultAnimation;

  bool showSubmitPopup = false;
  bool isShowSample = false;
  bool isInitialized = false;
  bool isShowResult = false;
  late String problemCode;
  DateTime? submissionTime;
  late int currentProblemNumber;
  late int totalProblemCount;
  late int childId;

  Future<void> init(String problemCode) async {
    this.problemCode = problemCode;
    childId = (await SecureStorageService.getChildId())!;

    // 1. SharedPreferences에 저장된 기록 불러오기
    final saved = await EnProblemService.loadProblemResults(problemCode, childId);

    // 2. provider에 반영
    ref.read(problemProgressProvider.notifier).setFromStorage(saved);
    // ✅ 로그 출력
    final progress = ref.read(problemProgressProvider);
    debugPrint("📦 불러온 문제 기록: $progress");

    // 3. 진행 중 문제 저장
    EnProblemService.saveContinueProblem(problemCode, childId);

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
      "images": problem["images"],
      "result": answer["value"],
      "object" : problem["object"],
      "correctController": AnimationController(
        vsync: ticker,
        duration: const Duration(milliseconds: 800),
      ),
      "wrongController": AnimationController(
        vsync: ticker,
        duration: const Duration(milliseconds: 500),
      ),
      "selectedValue": 0,
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
    resultController = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 400),
    );

    popAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: popController, curve: Curves.elasticOut),
    );
    submitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: submitController, curve: Curves.elasticOut),
    );
    resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: resultController, curve: Curves.elasticOut),
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
    if (selectedValue != 0) {
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

  void showResult() async {
    isShowResult = true;
    resultController.forward(from: 0);
    onUpdate();
  }

  void dispose() {
    (problemData["correctController"] as AnimationController).dispose();
    (problemData["wrongController"] as AnimationController).dispose();
    popController.dispose();
    submitController.dispose();
    resultController.dispose();
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

  Future<Map<String, dynamic>> getResult() async {
    final saved = await EnProblemService.loadProblemResults(
      problemCode,
      childId,
    );

    final correctCount = saved.values.where((v) => v == true).length;
    final totalCount = saved.length;

    final result = {
      "correct": correctCount,
      "wrong": totalCount - correctCount,
    };

    return result;
  }

  void end() async {
    await EnProblemService.clearChapterProblem(childId, problemCode);
    Modular.to.pop();
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

      showResult();
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