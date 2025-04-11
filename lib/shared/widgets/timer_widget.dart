// lib/shared/widgets/timer_widget.dart
import 'package:flutter/material.dart';
import '../controllers/timer_controller.dart';

// 써야할 페이지에 해당 변수 추가
// final TimerController _timerController = TimerController();
// int? elapsedTimeInMilliseconds;

// initState에 _timerController.start(); 추가

// 해당 기능 추가해야 페이지 떠날때 타이머 초기화
// @override
// void dispose() {
//   _timerController.dispose();
//   super.dispose();
// }

// 이렇게 쓰고싶은곳에 쓰면됨.
// TimerWidget(
// controller: _timerController,
// textStyle: const TextStyle(
//   fontSize: 18,
//   fontWeight: FontWeight.bold,
//   color: Colors.blue,
// ),

class TimerWidget extends StatefulWidget {
  final TimerController controller;
  final TextStyle? textStyle;
  final bool showMilliseconds;

  const TimerWidget({
    super.key,
    required this.controller,
    this.textStyle,
    this.showMilliseconds = true,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  int _timeInMilliseconds = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize((time) {
      setState(() {
        _timeInMilliseconds = time;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(_timeInMilliseconds),
      style:
          widget.textStyle ??
          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).floor();
    return seconds.toString(); // 초 단위로만 반환
  }
}
