import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/controllers/timer_controller.dart';
import 'package:nansan_flutter/shared/widgets/button_widget.dart';
import 'package:nansan_flutter/shared/widgets/header_widget.dart';
import 'package:nansan_flutter/shared/widgets/question_text.dart';
import 'package:nansan_flutter/shared/widgets/timer_widget.dart';

class LevelOneThreeOneThink1 extends StatefulWidget {
  const LevelOneThreeOneThink1({super.key});

  @override
  State<LevelOneThreeOneThink1> createState() => _LevelOneThreeOneThink1State();
}

class _LevelOneThreeOneThink1State extends State<LevelOneThreeOneThink1> {
  final TimerController _timerController = TimerController();
  int? elapsedTimeInMilliseconds;

  @override
  void initState() {
    super.initState();
    _timerController.start();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('수량 변별')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            HeaderWidget(headerText: '개념학습활동'),
            SizedBox(height: 16),
            QuestionTextWidget(
              questionText: '1. 사과는 몇 개인가요? <보기> 와 같이 네모칸 안에 알맞은 숫자를 써 봅시다.',
            ),
            SizedBox(height: 30),
            TimerWidget(controller: _timerController),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ButtonWidget(
                  height: 40,
                  width: 120,
                  buttonText: "제출하기",
                  fontSize: 15,
                  borderRadius: 10,
                ),
                SizedBox(width: 20),
                ButtonWidget(
                  height: 40,
                  width: 120,
                  buttonText: "다음문제",
                  fontSize: 15,
                  borderRadius: 10,
                  onPressed: () {
                    // 다음 문제로 이동하는 로직
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
