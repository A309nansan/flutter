import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:nansan_flutter/modules/drag_drop/controllers/drag_drop_controller.dart';
import 'package:nansan_flutter/modules/level_api/models/submit_request.dart';
import 'package:nansan_flutter/modules/level_api/services/problem_api_service.dart';
import 'package:nansan_flutter/shared/controllers/timer_controller.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/foundation.dart';

class Level112ThinkController extends ChangeNotifier {
  final ProblemApiService _apiService = ProblemApiService();
  final ScreenshotController _screenshotController = ScreenshotController();
  final TimerController _timerController = TimerController();
  final DragDropController _dragDropController = DragDropController();
  late int childId;
  late int current;
  late int total;
  late Map problemData;
  late Map answerData;
  late Map<String, dynamic> selectedAnswers;
  late String nextProblemCode;
  String problemCode;
  bool isLoading = true;
  bool isSubmitted = false;
  bool isCorrect = false;
  bool isEnd = false;
  bool showSubmitPopup = false;
  List<List<String>> fixedImageUrls = [];
  List<Map<String, String>> candidates = [];

  Level112ThinkController({required this.problemCode}) {
    _loadQuestionData();
    _timerController.start();
    isEnd = nextProblemCode.isEmpty;
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  // 문제 데이터 받아오는 함수
  Future<void> _loadQuestionData() async {
    try {
      final response = await _apiService.loadProblemData(problemCode);

      nextProblemCode = response.nextProblemCode;
      problemCode = response.problemCode;
      problemData = response.problem;
      answerData = response.answer;
      current = response.current;
      total = response.total;

      _processProblemData(problemData);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading question data: $e');
    }
  }

  // 문제 제출 함수
  Future<void> _submitAnswer() async {
    _timerController.stop();

    if (isSubmitted) return;
    final submitRequest = SubmitRequest(
      childId: childId,
      problemCode: problemCode,
      dateTime: DateTime.now().toIso8601String(),
      solvingTime: _timerController.elapsedSeconds,
      isCorrected: isCorrect,
      problem: problemData,
      answer: answerData,
      input: selectedAnswers,
    );

    try {
      await _apiService.submitAnswer(jsonEncode(submitRequest.toJson()));
      isSubmitted = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Submit error: $e');
    }
  }

  // 문제 데이터 처리 함수
  void _processProblemData(Map problemData) {
    final Map<String, dynamic> fixedCardUrl = problemData['fixed'];
    final fixedcategories = {'dot', 'numeric1', 'hangeul1'};
    String? dynamicCategory;

    for (var key in fixedCardUrl.keys) {
      if (!fixedcategories.contains(key)) {
        dynamicCategory = key;
        break;
      }
    }

    fixedImageUrls = [
      if (dynamicCategory != null)
        (fixedCardUrl[dynamicCategory] as List<dynamic>).cast<String>(),
      (fixedCardUrl['dot'] ?? []).cast<String>(),
      (fixedCardUrl['numeric1'] ?? []).cast<String>(),
      (fixedCardUrl['hangeul1'] ?? []).cast<String>(),
    ];

    final List<dynamic> candidateList = problemData['candidates'];

    candidates =
        candidateList
            .map(
              (c) => {
                'image_name': c['image_name'].toString(),
                'image_url': c['image_url'].toString(),
              },
            )
            .toList();
  }

  void _processInputData() {
    final Map<String, dynamic> cardUrl = problemData['fixed'];
    final categories = {'dot', 'numeric1', 'hangeul1'};
    String? dynamicCategory;

    for (var key in cardUrl.keys) {
      if (!categories.contains(key)) {
        dynamicCategory = key;
        break;
      }
    }

    final gridData = List.generate(
      4,
      (_) => List<Map<String, dynamic>?>.filled(3, null),
    );

    _dragDropController.zoneCards.forEach((zoneKey, cardData) {
      if (cardData != null) {
        final row = (zoneKey - 1) ~/ 3; // 0-based row index (0~3)
        final col = (zoneKey - 1) % 3; // 0-based column index (0~2)
        gridData[row][col] = {'image_name': cardData.imageName};
      }
    });

    // 최종 데이터 구조 변환
    selectedAnswers['$dynamicCategory'] = gridData[0];
    selectedAnswers['dot'] = gridData[1];
    selectedAnswers['hangeul1'] = gridData[3];
    selectedAnswers['numeric1'] = gridData[2];
  }

  void checkAnswer() {
    isCorrect = DeepCollectionEquality().equals(answerData, selectedAnswers);
    _submitAnswer();
  }
  
}
