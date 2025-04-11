// level_one_one_one_controller.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/level_1/1_1/models/answer_candidate.dart';
import 'package:nansan_flutter/modules/level_api/models/submit_request.dart';
import 'package:nansan_flutter/modules/level_api/services/problem_api_service.dart';
import 'package:nansan_flutter/shared/services/en_problem_service.dart';
import 'package:nansan_flutter/shared/services/image_service.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:nansan_flutter/shared/controllers/timer_controller.dart';
import 'package:screenshot/screenshot.dart';

class LevelOneOneOneController extends ChangeNotifier {
  final ProblemApiService _apiService = ProblemApiService();
  final TimerController timerController = TimerController();
  final ScreenshotController screenshotController = ScreenshotController();
  final String problemCode;
  String nextProblemCode = '';
  int? elapsedSeconds;
  int childId = 0;
  Map<String, dynamic> problemData = {};
  Map<String, dynamic> answerData = {};
  bool isCorrect = false;
  bool isSubmitted = false;
  bool isEnd = false;
  bool isLoading = true;
  int current = 1;
  int total = 1;

  // 페이지별 특수항목
  List<AnswerCandidate> candidates = [];
  List<String> selectedAnswers = [];
  int targetNumber = 0;
  int targetCount = 0;

  LevelOneOneOneController({required this.problemCode}) {
    loadQuestionData();
    timerController.start();
    isEnd = nextProblemCode.isEmpty;
  }

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }

  Future<void> loadQuestionData() async {
    try {
      final response = await _apiService.loadProblemData(problemCode);

      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      childId = childProfile['id'];

      targetNumber = response.answer['number'] as int? ?? 0;
      targetCount = response.answer['count'] as int? ?? 0;
      problemData = response.problem;
      answerData = response.answer;

      current = response.current;
      total = response.total;

      // 수정된 데이터 처리 부분
      final candidatesData =
          problemData.entries
              .where((entry) => entry.key.startsWith('candidate'))
              .map(
                (entry) => {
                  'image_url': entry.value['image_url'],
                  'number': entry.value['number'],
                  'key': entry.key,
                },
              )
              .toList();

      candidates =
          candidatesData.map((e) => AnswerCandidate.fromJson(e)).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading question data: $e');
    }
  }

  void handleSelection(String? key) {
    if (key == null) return;

    if (selectedAnswers.contains(key)) {
      selectedAnswers.remove(key);
    } else {
      selectedAnswers.add(key);
    }

    notifyListeners();
  }

  void checkAnswer() {
    elapsedSeconds = timerController.elapsedSeconds;
    timerController.stop();

    bool isCountValid = selectedAnswers.length == targetCount;
    bool areNumbersValid = true;

    for (String key in selectedAnswers) {
      final candidate = candidates.firstWhere(
        (c) => c.key == key,
        orElse:
            () => AnswerCandidate(number: -1, key: 'invalid', imageUrl: null),
      );

      if (candidate.number != targetNumber) {
        areNumbersValid = false;
        break;
      }
    }

    isCorrect = isCountValid && areNumbersValid;
    submitAnswer();
    isSubmitted = true;
    notifyListeners();
  }

  Future<void> submitAnswer() async {
    if (isSubmitted) return;

    final submitRequest = SubmitRequest(
      childId: childId,
      problemCode: problemCode,
      dateTime: DateTime.now().toIso8601String(),
      solvingTime: elapsedSeconds ?? 0,
      isCorrected: isCorrect,
      problem: problemData,
      answer: answerData,
      input: {"selected": selectedAnswers},
    );

    try {
      await _apiService.submitAnswer(jsonEncode(submitRequest.toJson()));
      isSubmitted = true;
      notifyListeners();
      debugPrint('제출성공.');
    } catch (e) {
      debugPrint('답변 제출 오류: $e');
    }
  }

  void onNextPressed() {
    final nextCode = nextProblemCode;
    if (nextCode.isEmpty) {
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

  String eulrul(int number) => [1, 3, 6, 7, 8].contains(number) ? '을' : '를';

  Future<void> submitActivity(BuildContext context) async {
    try {
      final imageBytes = await screenshotController.capture() as Uint8List;
      if (!context.mounted) return;

      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      final childId = childProfile['id'];

      await ImageService.uploadImage(
        imageBytes: imageBytes,
        childId: childId,
        localDateTime: DateTime.now(),
      );
    } catch (e) {
      debugPrint("이미지 캡처 중 오류 발생: $e");
    }
  }
}
