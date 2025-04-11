import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:nansan_flutter/modules/math/src/widgets/m_presentation/progress_divider.dart';
import '../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../models/m_problem_metadata.dart';
import '../../services/m_response.dart';
import '../../utils/math_basic.dart';
import '../../utils/math_ui_constant.dart';
import '../m_presentation/m_input_list.dart';
import '../m_presentation/m_present_division_list.dart';

class MProblemDiv extends StatelessWidget {
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

  const MProblemDiv({
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
    final String problemStr = "${mathData.num2}|${mathData.num1}";
    final List<List<String>> problemToList = [problemStr.split('')];
    print(problemStr + "PROBLEMSTR");
    List<List<List<Stroke>>> carryStrokes = userResponse.carryStrokes;
    List<List<List<Stroke>>> progressStrokes = userResponse.progressStrokes;
    List<List<List<Stroke>>> answerStrokes = userResponse.answerStrokes;
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
      child: Align(
        alignment: Alignment.center,
        child: IntrinsicWidth(
          child: Row( children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MInputList(
                  itemCount: mathData.matrixVolume[5],
                  recognitionZoneKeys: recognitionAnswerZoneKeys[0],
                  strokeList: answerStrokes[0],
                ),
                // ProgressDivider(
                //   wCount: 2 + (wSize * 0.0011),
                //   isDivision: true,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [MPresentDivisionList(gridData: problemToList)],
                ),

                //SizedBox(height: hSize * 0.2),
                MInputList(
                  itemCount: mathData.matrixVolume[5],
                  recognitionZoneKeys: recognitionProgressZoneKeys[0],
                  strokeList: progressStrokes[0],
                ),
                ProgressDivider(wCount: 2),
                MInputList(
                  itemCount: mathData.matrixVolume[5],
                  recognitionZoneKeys: recognitionProgressZoneKeys[1],
                  strokeList: progressStrokes[1],
                ),
                if (mathData.matrixVolume[2] == 4)
                  MInputList(
                    itemCount: mathData.matrixVolume[5],
                    recognitionZoneKeys: recognitionProgressZoneKeys[2],
                    strokeList: progressStrokes[2],
                  ),

                if (mathData.matrixVolume[2] == 4)
                  ProgressDivider(wCount: 2),
                if (mathData.matrixVolume[2] == 4)
                  MInputList(
                    itemCount: mathData.matrixVolume[5],
                    recognitionZoneKeys: recognitionProgressZoneKeys[3],
                    strokeList: progressStrokes[3],
                  ),
              ],
            ),
            SizedBox(width : wSize*0.5)
          ])
        ),
      ),
    );
  }
}
