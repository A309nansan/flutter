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

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                      height: screenHeight * 0.3,
                      width: screenWidth * 0.85,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.orangeAccent,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: screenWidth * 0.75,
                              height: screenHeight * 0.1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  final contents = ['1', '', '3', '○', '5'];//데이터 넣기

                                  return Container(
                                    height: screenHeight * 0.06,
                                    width:  screenWidth * 0.15,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFef1c4),
                                      border: Border.all(color: Color(0xFF9c6a17)),
                                    ),
                                    child: Center(
                                        child: contents[index] == '○'
                                            ? Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 2,
                                              )
                                          ),
                                        )
                                            :
                                        Text(
                                          contents[index],
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                    ),
                                  );
                                }),
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Image.asset(
                              'assets/images/logo1.png', //화살표 구현
                              width: screenWidth * 0.3,
                              height: screenHeight * 0.06,
                            ),
                          ),
                          SizedBox(
                              child: Container(
                                height: screenHeight * 0.06,
                                width:  screenWidth * 0.15,
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFef1c4),
                                  border: Border.all(color: Color(0xFF9c6a17)),
                                ),
                                child: Center(
                                  child: Text(
                                    'Num',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                          ),
                        ],
                      )
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: const Text(
                        "<보기>",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Column(
              children: [
                SizedBox(
                  width: screenWidth * 0.75,
                  height: screenHeight * 0.1,
                  child: GridView.count(
                    crossAxisCount: 5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    childAspectRatio: 1.5,
                    children: List.generate(5, (index) {
                      final contents2 = ['5', null, '7', null, '8']; // 예시용
                      final isSelectable = contents2[index] == null;
                      final isSelected = selectedIndex == index;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.15,
                            height: screenHeight * 0.1,
                            child: ElevatedButton(
                              onPressed: isSelectable
                                  ? () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFef1c4),
                                foregroundColor: Colors.black,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                  side: const BorderSide(color: Color(0xFF9c6a17)),
                                ),
                                padding: const EdgeInsets.all(5.0),
                                disabledBackgroundColor: const Color(0xFFFef1c4),
                                disabledForegroundColor: Colors.black,
                              ),
                              child: contents2[index] != null
                                  ? Text(
                                '$givenNumber',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                                  : const SizedBox.shrink(),
                            ),
                          ),

                          if (isSelected)
                            Positioned(
                              child: IgnorePointer(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Image.asset(
                    'assets/images/logo2.png', //화살표 구현하기
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.06,
                  ),
                ),
                SizedBox(
                    child: Container(
                      height: screenHeight * 0.06,
                      width:  screenWidth * 0.15,
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFFef1c4),
                        border: Border.all(color: Color(0xFF9c6a17)),
                      ),
                      child: Center(
                        child: Text(
                          'Num',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                ),
              ],
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