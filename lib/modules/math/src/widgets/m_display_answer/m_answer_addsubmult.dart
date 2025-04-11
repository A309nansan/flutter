import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/m_problem_metadata.dart';
import '../../services/m_response.dart';
import '../../utils/math_basic.dart';
import '../../utils/math_ui_constant.dart';
import '../m_presentation/m_answer_list.dart';
import '../m_presentation/m_present_matrix.dart';
import '../m_presentation/progress_divider.dart';
class MAnswerAddSubMult extends StatelessWidget {
  final MProblemMetadata mathData;
  final MResponse userResponse;
  final List<List<List<String>>> answer;
  final bool isShowingUserInput;
  final VoidCallback? onCleared;
  const MAnswerAddSubMult({
    Key? key,
    required this.mathData,
    required this.userResponse,
    required this.answer,
    required this.isShowingUserInput,
    this.onCleared,
  }) : super(key: key);

  void _clear(){
    onCleared?.call();
  }
  @override
  Widget build(BuildContext context) {
    double wSize = MathUIConstant.wSize;

    double problemLen = max(mathData.num1.toString().length, mathData.num2.toString().length) + 1;
    int problemSize = getMatrixRows(mathData.num1, mathData.num2);
    List<List<String>> problemToList = formatMathProblem(
      mathData.num1.toString(),
      mathData.num2.toString(),
      opConvert(mathData.operator),
      problemSize,
    );


    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // 배경색 (필요에 따라 변경 가능)
        border: Border.all(
          color: MathUIConstant.boundaryCyan, // 테두리 색상
          width: 3, // 테두리 두께
        ),
        borderRadius: BorderRadius.circular(16), // 둥근 모서리
      ),
      child:
          Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for(int i = 0; i<mathData.matrixVolume[0]; i++)...[
                  MAnswerList(
                    itemCount: mathData.matrixVolume[1],
                    recognizedResults: userResponse.recognitionCarryResults[i],
                    expectedResults: answer[0][i],
                    isShowingUserInput: isShowingUserInput

                  ),
                  //SizedBox(height: wSize * 0.1), // 간격 조정
                ],
                //SizedBox(height: wSize * 0.1),
                MPresentMatrix(
                    gridData: problemToList,
                    operator: mathData.operator,

                ),
                if (mathData.matrixVolume[2] != 0) ProgressDivider(
                  wCount: max(mathData.matrixVolume[5] + 0, problemLen) ,),
                for(int i = 0; i<mathData.matrixVolume[2]; i++)...[
                  MAnswerList(
                    itemCount: mathData.matrixVolume[3],
                    recognizedResults: userResponse.recognitionProgressResults[i],
                    expectedResults: answer[1][i],
                      isShowingUserInput: isShowingUserInput
                  ),
                  //SizedBox(height: wSize * 0.1), // 간격 조정
                ],
                SizedBox(height: wSize * 0.1),
                ProgressDivider(
                  wCount: max(mathData.matrixVolume[5] + 0, problemLen)  ,),
                MAnswerList(
                  itemCount: mathData.matrixVolume[5],
                  recognizedResults: userResponse.recognitionAnswerResults[0],
                  expectedResults: answer[2][0],
                    isShowingUserInput: isShowingUserInput
                ),
              ],
            )
          )
      // 오른쪽 끝에 두 버튼을 가깝게 정
    );
  }
}