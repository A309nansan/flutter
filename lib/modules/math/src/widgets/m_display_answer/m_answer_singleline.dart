import 'package:flutter/material.dart';
import '../../models/m_problem_metadata.dart';
import '../../services/m_response.dart';
import '../../utils/math_basic.dart';
import '../../utils/math_ui_constant.dart';
import '../m_presentation/m_answer_list.dart';
import '../m_presentation/m_present_matrix_singleline.dart';

class MAnswerSingleline extends StatelessWidget {
  final MProblemMetadata mathData;
  final MResponse userResponse;
  final List<List<List<String>>> answer;
  final bool isShowingUserInput;
  final VoidCallback? onCleared;

  const MAnswerSingleline({
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
    final String problemStr =
        "${mathData.num1}${opConvert(mathData.operator)}${mathData.num2}=";
    final List<List<String>> problemToList = [problemStr.split('')];
    double hSize = MathUIConstant.hSize;

    return Center(
      child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MPresentMatrixSingleline(gridData: problemToList),
              SizedBox(height: hSize*0.3),
              MAnswerList(
                itemCount: mathData.matrixVolume[5],
                recognizedResults: userResponse.recognitionAnswerResults[0],
                expectedResults: answer[2][0],
                isShowingUserInput: isShowingUserInput,
              ),
            ],
          ),

    );
  }
}
