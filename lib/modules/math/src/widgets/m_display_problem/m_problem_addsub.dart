import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import '../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../models/m_problem_metadata.dart';
import '../../services/m_response.dart';
import '../../utils/math_basic.dart';
import '../../utils/math_ui_constant.dart';
import '../m_presentation/m_input_list.dart';
import '../m_presentation/m_present_matrix.dart';
import '../m_presentation/progress_divider.dart';

class MProblemAddSub extends StatelessWidget {
  final MProblemMetadata mathData;
  final Function(List<List<List<String>>>)? onResultUpdated;
  final List<List<List<String>>> initialResult;
  final List<List<GlobalKey<HandwritingRecognitionZoneState>>>
  recognitionCarryZoneKeys;
  final List<List<GlobalKey<HandwritingRecognitionZoneState>>>
  recognitionProgressZoneKeys;
  final List<List<GlobalKey<HandwritingRecognitionZoneState>>>
  recognitionAnswerZoneKeys;
  final MResponse userResponse;
  final VoidCallback? onCleared;

  const MProblemAddSub({
    Key? key,
    required this.mathData,
    required this.onResultUpdated,
    required this.initialResult,
    required this.userResponse,
    required this.recognitionCarryZoneKeys,
    required this.recognitionProgressZoneKeys,
    required this.recognitionAnswerZoneKeys,

    this.onCleared,
  }) : super(key: key);

  void _clearAll() {
    clearDrawingState([recognitionCarryZoneKeys, recognitionAnswerZoneKeys]);
    onCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    double hSize = MathUIConstant.hSize;
    int problemSize = getMatrixRows(mathData.num1, mathData.num2);
    List<List<String>> problemToList = formatMathProblem(
      mathData.num1.toString(),
      mathData.num2.toString(),
      opConvert(mathData.operator),
      problemSize,
    );
    double problemLen =
        max(mathData.num1.toString().length, mathData.num2.toString().length) +
        1;
    List<GlobalKey<HandwritingRecognitionZoneState>> CarryKeys = [];
    if (recognitionCarryZoneKeys.isNotEmpty)
      CarryKeys = recognitionCarryZoneKeys[0];
    List<List<List<Stroke>>> carryStrokes = userResponse.carryStrokes;
    List<List<List<Stroke>>> answerStrokes = userResponse.answerStrokes;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // 배경색 (필요에 따라 변경 가능)
        border: Border.all(
          color: MathUIConstant.boundaryCyan, // 테두리 색상
          width: 3, // 테두리 두께
        ),
        borderRadius: BorderRadius.circular(16), // 둥근 모서리
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 배경색 (필요에 따라 변경 가능)
          border: Border.all(
            color: MathUIConstant.boundaryGreen, // 테두리 색상
            width: 3, // 테두리 두께
          ),
          borderRadius: BorderRadius.circular(16), // 둥근 모서리
        ),
        child:Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (mathData.matrixVolume[0] != 0)
                MInputList(
                  itemCount: mathData.matrixVolume[1],
                  recognitionZoneKeys: CarryKeys,
                  strokeList: carryStrokes[0],
                ),
              MPresentMatrix(
                gridData: problemToList,
                operator: mathData.operator,
              ),
              SizedBox(height: hSize * 0.1), // 간격 조정
              ProgressDivider(
                wCount: max(mathData.matrixVolume[5] + 0, problemLen),
              ),
              MInputList(
                itemCount: mathData.matrixVolume[5],
                recognitionZoneKeys: recognitionAnswerZoneKeys[0],
                strokeList: answerStrokes[0],
              ),
            ],
          ),
        ),
      )
      // 오른쪽 끝에 두 버튼을 가깝게 정
    );
  }
}
