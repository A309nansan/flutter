import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../utils/math_basic.dart';
import '../../utils/math_data_utils.dart';
import '../../utils/math_string_hardcoder.dart';
import '../../utils/math_ui_constant.dart';
import '../drawing_canvas.dart';
import '../return_answer_page.dart';
import 'package:fitted_scale/fitted_scale.dart';

class MProblemStatTile extends StatefulWidget {
  final int index;
  final String mapKey;
  final Map<String, dynamic> problem;
  final dynamic problemBundle;
  final int categoryIndex;

  const MProblemStatTile({
    super.key,
    required this.index,
    required this.mapKey,
    required this.problem,
    required this.problemBundle,
    required this.categoryIndex,
  });

  @override
  State<MProblemStatTile> createState() => _MProblemStatTileState();
}

class _MProblemStatTileState extends State<MProblemStatTile> {
  final GlobalKey _leftBoxKey = GlobalKey();
  double? _leftBoxHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final boxContext = _leftBoxKey.currentContext;
      if (boxContext != null && mounted) {
        final renderBox = boxContext.findRenderObject() as RenderBox;
        const double minHeight = 300; // 원하는 최소 높이
        setState(() {
          _leftBoxHeight =
              renderBox.size.height >= minHeight
                  ? renderBox.size.height
                  : minHeight;
        });
      }
    });
  }

  bool isExpanded = false;
  double mqc = MathUIConstant.MQC;

  @override
  Widget build(BuildContext context) {
    const double fallbackHeight = 200;
    const double minHeight = 120;

    double rightBoxHeight = (_leftBoxHeight ?? fallbackHeight);
    rightBoxHeight = rightBoxHeight < minHeight ? minHeight : rightBoxHeight;
    final number = widget.problem["problemNumber"];
    final time = widget.problem["solvedTime"];
    final correct = widget.problem["correct"];
    final List<String> errorCodesRaw =
        (widget.problem["errorCodes"] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final List<String> errorCodes = returnErrorTypeList(errorCodesRaw);
    final List<String> errorCodes2 = returnErrorTypeSubList(errorCodesRaw);
    final num1 = widget.problemBundle.problemMetaData.num1;
    final num2 = widget.problemBundle.problemMetaData.num2;
    final operator = widget.problemBundle.problemMetaData.operator;
    final op = opConvert(operator);
    final answer = formatAnswer(num1, num2, operator);
    final basaTotalScore = widget.problem["basaTotalScore"];
    final basaUserScore = widget.problem["basaUserScore"];


    return Container(
      margin: EdgeInsets.symmetric(vertical: 12 * mqc, horizontal: 16 * mqc),
      decoration: BoxDecoration(
        border: Border.all(
          color: correct ? Colors.grey.shade300 : Colors.redAccent,
          width: 2 * mqc,
        ),
        borderRadius: BorderRadius.circular(12 * mqc),
        color: Colors.white,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // ✅ 상하단 경계선 제거
        ),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              isExpanded = expanded;
              if (expanded) {
                // 다음 프레임에서 높이 측정
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final boxContext = _leftBoxKey.currentContext;
                  if (boxContext != null && mounted) {
                    final renderBox =
                        boxContext.findRenderObject() as RenderBox;
                    setState(() {
                      _leftBoxHeight = renderBox.size.height;
                    });
                  }
                });
              }
            });
          },
          title: ProblemTitle(
            number: number,
            num1: num1,
            num2: num2,
            op: op,
            answer: answer,
            correct: correct,
            mqc: mqc,
          ),
          childrenPadding: EdgeInsets.symmetric(
            horizontal: 16 * mqc,
            vertical: 8 * mqc,
          ),
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // ✅ 왼쪽 상단 펜 아이콘
                      Container(
                        key: _leftBoxKey,
                        constraints: BoxConstraints(
                          minHeight: 350, // 원하는 최소 높이 설정
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 100,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: FittedScale(
                          scale:
                              MathUIConstant.statsTransformConstant(
                                widget.categoryIndex,
                              ) *
                              1.1,
                          child: GestureDetector(
                            onTap: _showDrawingDialog,
                            child: buildAnswerWidget(
                              mathData: widget.problemBundle.problemMetaData,
                              userResponse: widget.problemBundle.userResponse,
                              answer:
                                  widget.problemBundle.correctResponse3DList,
                              isShowingUserInput: true,
                              onCleared: () {},
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: IgnorePointer(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.transparent, // 배경색 (필요에 따라 변경 가능)
                              border: Border.all(
                                color: Colors.grey,
                                width: 1, // 테두리 두께
                              ),
                              borderRadius: BorderRadius.circular(40), // 둥근 모서리
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 25,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 30 * mqc),
                  // 오른쪽 위젯 (크기 변화 감지 가능하게)
                  Flexible(
                    child: Container(
                      height: max(rightBoxHeight, 350),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white, // 배경색 (필요에 따라 변경 가능)
                        border: Border.all(
                          color: Color(0xFFDDDDDD),
                          width: 2, // 테두리 두께
                        ),
                        borderRadius: BorderRadius.circular(16), // 둥근 모서리
                      ),
                      child: Stack(
                        alignment:Alignment.center,
                        children: [
                          if (correct)
                            Opacity(
                              opacity: 0.3,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double imageWidth = constraints.maxWidth;
                                  return Image.asset(
                                    'assets/images/basa_math/thumbsup.png',
                                    width: imageWidth,
                                    fit: BoxFit.contain,
                                  );
                                },
                              ),
                            ),
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        correct ? "정답입니다!" : "오답입니다..",
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                          color: correct ? Colors.green : Colors.redAccent,
                                        ),
                                      ),
                                      //if (!correct)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            "점수: $basaUserScore / $basaTotalScore",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: correct? Colors.green: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  Spacer(flex: 2), // 👈 이게 하단으로 밀어냄
                                  // ✅ 중간 오류유형 정보
                                  if (!correct && errorCodes.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 12),
                                        Text(
                                          "🛠️ 오류유형",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                errorCodes.join(', '),
                                                style: const TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                errorCodes2.join('\n'),
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                  // ✅ 하단 풀이 시간
                                  Spacer(flex: 8), // 👈 이게 하단으로 밀어냄

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "⏱ $time초",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // ✅ Column이 Stack을 꽉 채우도록 설정
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showDrawingDialog() {
    showDialog(
      context: context,
      builder: (_) {
        final key = GlobalKey<HandwritingRecognitionZoneState>();
        return AlertDialog(
          title: Row(
            //mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                'assets/images/basa_math/bunny_detector.png',
                width: 75 * mqc,
                height: 75 * mqc,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 155 * mqc),
              Text(
                '다시 풀어보기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24 * mqc,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(8.0),
          content: SizedBox(
            width: MathUIConstant.statsDialogWidth,
            height: MathUIConstant.statsDialogHeight,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  alignment: const Alignment(0, -0.2),
                  child: Transform.scale(
                    scale: 0.8,
                    alignment: Alignment.topCenter,
                    child: IntrinsicHeight(
                      child: buildAnswerWidget(
                        mathData: widget.problemBundle.problemMetaData,
                        userResponse: widget.problemBundle.userResponse,
                        answer: widget.problemBundle.correctResponse3DList,
                        isShowingUserInput: true,
                        onCleared: () {},
                      ),
                    ),
                  ),
                ),
                DrawingCanvas(
                  width: MathUIConstant.statsDialogWidth,
                  height: MathUIConstant.statsDialogHeight - 100,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}

class ProblemTitle extends StatelessWidget {
  final int number;
  final int num1;
  final int num2;
  final String op;
  final String answer;
  final bool correct;
  final double mqc;

  const ProblemTitle({
    super.key,
    required this.number,
    required this.num1,
    required this.num2,
    required this.op,
    required this.answer,
    required this.correct,
    required this.mqc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "문제 $number:",
              style: TextStyle(fontSize: 18 * mqc, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 30 * mqc),
            Text(
              "$num1 $op $num2 = $answer",
              style: TextStyle(fontSize: 24 * mqc, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 30 * mqc,
              height: 30 * mqc,
              child:
                  !correct
                      ? Text(
                        '❌',
                        style: TextStyle(
                          fontSize: 18 * mqc,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 28 * mqc,
                            height: 28 * mqc,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 18 * mqc,
                            height: 18 * mqc,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
            ),
            Text(
              correct ? ' 정답' : ' 오답',
              style: TextStyle(fontSize: 24 * mqc, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
