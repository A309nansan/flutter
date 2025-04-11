import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/m_problem_metadata.dart';
import '../../services/m_response.dart';
import '../../utils/math_ui_constant.dart';
import '../m_presentation/m_answer_list.dart';
import '../m_presentation/m_present_division_list.dart';
import '../m_presentation/progress_divider.dart';

class MAnswerDivRemainder extends StatelessWidget {
  final MProblemMetadata mathData;
  final MResponse userResponse;
  final List<List<List<String>>> answer;
  final bool isShowingUserInput;
  final VoidCallback? onCleared;

  const MAnswerDivRemainder({
    Key? key,
    required this.mathData,
    required this.userResponse,
    required this.answer,
    required this.isShowingUserInput,
    this.onCleared,
  }) : super(key: key);

  void _clear() {
    onCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    double wSize = MathUIConstant.wSize;
    double hSize = MathUIConstant.hSize;
    double opSize = MathUIConstant.opSize;
    final String problemStr = "${mathData.num2}|${mathData.num1}";
    final List<List<String>> problemToList = [problemStr.split('')];

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // 배경색 (필요에 따라 변경 가능)
        border: Border.all(
          color: MathUIConstant.boundaryCyan, // 테두리 색상
          width: 3, // 테두리 두께
        ),
        borderRadius: BorderRadius.circular(16), // 둥근 모서리
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MAnswerList(
                itemCount: mathData.matrixVolume[5],
                recognizedResults: userResponse.recognitionAnswerResults[0],
                expectedResults: answer[2][0],
                  isShowingUserInput: isShowingUserInput
              ),
              // ProgressDivider(
              //   wCount: 2 + wSize * 0.0011,
              //   isDivision: true,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [MPresentDivisionList(gridData: problemToList)],
              ),

              MAnswerList(
                itemCount: mathData.matrixVolume[5],
                recognizedResults: userResponse.recognitionProgressResults[0],
                expectedResults: answer[1][0],
                  isShowingUserInput: isShowingUserInput
              ),

              ProgressDivider(wCount: 2),
              MAnswerList(
                itemCount: mathData.matrixVolume[5],
                recognizedResults: userResponse.recognitionProgressResults[1],
                expectedResults: answer[1][1],
                  isShowingUserInput: isShowingUserInput
              ),

              if (mathData.matrixVolume[2] == 4)
                MAnswerList(
                  itemCount: mathData.matrixVolume[5],
                  recognizedResults: userResponse.recognitionProgressResults[2],
                  expectedResults: answer[1][2],
                    isShowingUserInput: isShowingUserInput
                ),

              if (mathData.matrixVolume[2] == 4)
                ProgressDivider(wCount: 2),
              if (mathData.matrixVolume[2] == 4)
                MAnswerList(
                  itemCount: mathData.matrixVolume[5],
                  recognizedResults: userResponse.recognitionProgressResults[3],
                  expectedResults: answer[1][3],
                    isShowingUserInput: isShowingUserInput
                ),
            ],
          ),
          Row(
            children: [
              Container(
                width: wSize,
                height: hSize,
                child: Center(child:Text(
                  '⋯',
                  style: TextStyle(
                    fontSize: opSize * 1.1, // 원하는 크기로 변경
                  ),
                ),),
              ),
              MAnswerList(
                itemCount: mathData.matrixVolume[1],
                recognizedResults: userResponse.recognitionCarryResults[0],
                expectedResults: answer[0][0],
                  isShowingUserInput: isShowingUserInput
              ),
              SizedBox(width: wSize * 0.5)
            ],
          ),
        ],
      ),
      // 오른쪽 끝에 두 버튼을 가깝게 정
    );
  }
}
