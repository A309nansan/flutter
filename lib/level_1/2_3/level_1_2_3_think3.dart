import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/level_1/2_3/widgets/clickable_container.dart';
import 'package:nansan_flutter/level_1/2_3/widgets/example_container.dart';
import 'package:nansan_flutter/modules/level_api/models/submit_request.dart';
import 'package:nansan_flutter/modules/level_api/services/problem_api_service.dart';
import 'package:nansan_flutter/shared/controllers/timer_controller.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:nansan_flutter/shared/widgets/button_widget.dart';
import 'package:nansan_flutter/shared/widgets/en_problem_splash_screen.dart';
import 'package:nansan_flutter/shared/widgets/header_widget.dart';
import 'package:nansan_flutter/shared/widgets/question_text.dart';

class LevelOneTwoThreeThink3 extends StatefulWidget {
  final String problemCode;
  const LevelOneTwoThreeThink3({super.key, required this.problemCode});

  @override
  State<LevelOneTwoThreeThink3> createState() => _LevelOneTwoThreeThink3State();
}

class _LevelOneTwoThreeThink3State extends State<LevelOneTwoThreeThink3> {
  // 필수코드
  final TimerController _timerController = TimerController();
  final ProblemApiService _apiService = ProblemApiService();
  int childId = 0;
  int? elapsedSeconds;
  int current = 1;
  int total = 1;
  String nextProblemCode = 'enlv1s2c3gn4';
  String problemCode = 'enlv1s2c3gn3';
  bool isAnswerSubmitted = false;
  bool isCorrect = false;
  bool isLoading = true;
  bool isEnd = false;
  Map<String, dynamic> problemData = {};
  Map<String, dynamic> answerData = {};
  Map<String, dynamic> selectedAnswers = {};

  //페이지별 변수
  List<int> numberList = [];
  int givenNumber = 0;

  @override
  void initState() {
    super.initState();
    // 비동기 로직 실행 후 UI 업데이트
    _loadQuestionData().then((_) {
      setState(() {
        isLoading = false;
      });
      _timerController.start();
      isEnd = nextProblemCode.isEmpty;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timerController.dispose();
    isAnswerSubmitted = false;
  }

  // problemcode에 따라 데이터 호출하는 함수
  Future<void> _loadQuestionData() async {
    try {
      final response = await _apiService.loadProblemData(problemCode);

      final childProfileJson = await SecureStorageService.getChildProfile();
      final childProfile = jsonDecode(childProfileJson!);
      childId = childProfile['id'];

      setState(() {
        nextProblemCode = response.nextProblemCode;
        problemCode = response.problemCode;

        // problem과 answer 데이터 저장
        problemData = response.problem;
        answerData = response.answer;
        current = response.current;
        total = response.total;
      });
      _processProblemData(problemData);
    } catch (e) {
      debugPrint('Error loading question data: $e');
    }
  }

  // 제출함수(제출하기 버튼 누를시 작동하도록 설정)
  Future<void> _submitAnswer() async {
    if (isAnswerSubmitted) return; // 이미 제출된 경우 중복 제출 방지

    // 현재 날짜와 시간 (ISO 8601 형식)
    final now = DateTime.now();
    final dateTime = now.toIso8601String();

    // SubmitRequest 객체 생성
    final submitRequest = SubmitRequest(
      childId: childId,
      problemCode: problemCode,
      dateTime: dateTime,
      solvingTime: elapsedSeconds ?? 0,
      isCorrected: isCorrect,
      problem: problemData,
      answer: answerData,
      input: selectedAnswers,
    );

    try {
      // API 서비스 호출
      await _apiService.submitAnswer(jsonEncode(submitRequest.toJson()));
      setState(() {
        isAnswerSubmitted = true;
      });
    } catch (e) {
      debugPrint('답변 제출 중 오류 발생: $e');
      // 오류 처리 (필요에 따라 사용자에게 알림)
    }
  }

  void _processProblemData(problemData) {
    numberList =
        (problemData['list'] as List<dynamic>).map((e) => e as int).toList();
    givenNumber = problemData['number'] as int;

    debugPrint('$numberList');
    debugPrint('$givenNumber');
  }

  void _processInputData() {}

  // 정답 체크하는 함수. 정답 체크로직 구현 필요.
  void checkAnswer() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('빠진 수 찾기')),
      body:
          isLoading
              ? const Center(child: EnProblemSplashScreen())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    numberList.isNotEmpty
                        ? Column(
                          children: [
                            SizedBox(height: 16),
                            HeaderWidget(headerText: '개념학습활동'),
                            SizedBox(height: 16),
                            QuestionTextWidget(
                              questionText:
                                  '숫자가 들어갈 알맞은 위치를 찾아 <보기> 와 같이 O표 하세요.',
                            ),
                            SizedBox(height: 15),
                            ExampleContainer(),
                            SizedBox(height: 30),
                            Container(
                              width: 600,
                              height: 300,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.amber,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 46),
                                  ClickableContainer(numberList: numberList),
                                  SizedBox(height: 120),
                                  Container(
                                    alignment: Alignment.center,
                                    width: 100,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade200,
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                    child: Text(
                                      '$givenNumber',
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ButtonWidget(
                                  width: 120,
                                  height: 60,
                                  buttonText: '제출하기',
                                  fontSize: 18,
                                ),
                                SizedBox(width: 10),
                                ButtonWidget(
                                  height: 60,
                                  width: 120,
                                  buttonText:
                                      nextProblemCode == '' ? '학습 완료' : '다음 문제',
                                  fontSize: 18,
                                  onPressed: () {
                                    var route =
                                        nextProblemCode == ''
                                            ? '/level1'
                                            : '/level1/$nextProblemCode';
                                    Modular.to.pushNamed(route);
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                        : const Center(child: CircularProgressIndicator()),
              ),
    );
  }
}
