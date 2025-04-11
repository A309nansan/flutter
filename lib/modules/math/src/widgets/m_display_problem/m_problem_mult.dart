import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:nansan_flutter/modules/math/src/services/m_response.dart';

import '../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../models/m_problem_metadata.dart';
import '../../utils/math_basic.dart';
import '../../utils/math_ui_constant.dart';
import '../m_presentation/m_input_list.dart';
import '../m_presentation/m_present_matrix.dart';
import '../m_presentation/progress_divider.dart';

class MProblemMult extends StatelessWidget {
  final MProblemMetadata mathData;
  final Function(List<List<List<String>>>)? onResultUpdated;
  final VoidCallback? onCleared;
  final List<List<List<String>>> initialResult;
  final List<List<GlobalKey<HandwritingRecognitionZoneState>>>
  recognitionCarryZoneKeys;
  final List<List<GlobalKey<HandwritingRecognitionZoneState>>>
  recognitionProgressZoneKeys;
  final List<List<GlobalKey<HandwritingRecognitionZoneState>>>
  recognitionAnswerZoneKeys;
  final MResponse userResponse;

  const MProblemMult({
    Key? key,
    required this.mathData,
    required this.onResultUpdated,
    required this.initialResult,
    required this.recognitionCarryZoneKeys,
    required this.recognitionProgressZoneKeys,
    required this.recognitionAnswerZoneKeys,
    required this.userResponse,
    this.onCleared,
  }) : super(key: key);

  void _clearAll() {
    clearDrawingState([
      recognitionCarryZoneKeys,
      recognitionProgressZoneKeys,
      recognitionAnswerZoneKeys,
    ]);
    onCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    double wSize = MathUIConstant.wSize;
    double hSize = MathUIConstant.hSize;
    double fSize = MathUIConstant.fSize;
    double opSize = MathUIConstant.opSize;
    double iconSize = MathUIConstant.iconSize;
    List<List<List<Stroke>>> carryStrokes = userResponse.carryStrokes;
    List<List<List<Stroke>>> progressStrokes = userResponse.progressStrokes;
    List<List<List<Stroke>>> answerStrokes = userResponse.answerStrokes;
    int problemSize = getMatrixRows(mathData.num1, mathData.num2);
    List<List<String>> problemToList = formatMathProblem(
      mathData.num1.toString(),
      mathData.num2.toString(),
      opConvert(mathData.operator),
      problemSize,
    );
    List<GlobalKey<HandwritingRecognitionZoneState>> CarryKeys = [];
    if (recognitionCarryZoneKeys.isNotEmpty)
      CarryKeys = recognitionCarryZoneKeys[0];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // 배경색 (필요에 따라 변경 가능)
        border: Border.all(
          color: MathUIConstant.boundaryCyan, // 테두리 색상
          width: 3, // 테두리 두께
        ),
        borderRadius: BorderRadius.circular(16), // 둥근 모서리
      ),
      child:
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // 배경색 (필요에 따라 변경 가능)
                border: Border.all(
                  color: MathUIConstant.boundaryGreen, // 테두리 색상
                  width: 3, // 테두리 두께
                ),
                borderRadius: BorderRadius.circular(16), // 둥근 모서리
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (int i = 0; i < mathData.matrixVolume[0]; i++) ...[
                    MInputList(
                      itemCount: mathData.matrixVolume[1],
                      recognitionZoneKeys: recognitionCarryZoneKeys[i],
                      strokeList: carryStrokes[i],
                    ),
                    //SizedBox(height: wSize * 0.1), // 간격 조정
                  ],
                  SizedBox(height: wSize * 0.1),
                  MPresentMatrix(
                    gridData: problemToList,
                    operator: mathData.operator,
                  ),
                  if (mathData.matrixVolume[2] != 0)
                    ProgressDivider(
                      wCount: mathData.matrixVolume[5] + 0,
                    ),
                  for (int i = 0; i < mathData.matrixVolume[2]; i++) ...[
                    MInputList(
                      itemCount: mathData.matrixVolume[3],
                      recognitionZoneKeys: recognitionProgressZoneKeys[i],
                      strokeList: progressStrokes[i],
                    ),

                  ],

                  ProgressDivider(
                    wCount: mathData.matrixVolume[5] + 0,
                  ),
                  MInputList(
                    itemCount: mathData.matrixVolume[5],
                    recognitionZoneKeys: recognitionAnswerZoneKeys[0],
                    strokeList: answerStrokes[0],
                  ),
                ],
              ),
            )
          ),
      // 오른쪽 끝에 두 버튼을 가깝게 정
    );
  }
}
