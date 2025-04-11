import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

import '../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../models/m_problem_metadata.dart';
import '../../services/m_response.dart';
import '../../utils/math_basic.dart';
import '../../utils/math_ui_constant.dart';

import '../m_presentation/m_input_list.dart';
import '../m_presentation/m_present_matrix_singleline.dart';


class MProblemSingleline extends StatelessWidget {
  final MProblemMetadata mathData;
  final Function(List<List<List<String>>>)? onResultUpdated;
  final List<List<List<String>>> initialResult;
  final List<List<GlobalKey<HandwritingRecognitionZoneState>>>
  recognitionAnswerZoneKeys;
  final VoidCallback? onCleared;
  final MResponse userResponse;

  const MProblemSingleline({
    Key? key,
    required this.mathData,
    required this.onResultUpdated,
    required this.initialResult,
    required this.recognitionAnswerZoneKeys,
    required this.userResponse,
    this.onCleared,
  }) : super(key: key);

  void _clearAll() {
    clearDrawingState([recognitionAnswerZoneKeys]);
    onCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    final String problemStr =
        "${mathData.num1}${opConvert(mathData.operator)}${mathData.num2}=";
    final List<List<String>> problemToList = [problemStr.split('')];
    final List<GlobalKey<HandwritingRecognitionZoneState>> answerKeys =
        recognitionAnswerZoneKeys[0];
    double hSize = MathUIConstant.hSize;
    List<List<List<Stroke>>> answerStrokes = userResponse.answerStrokes;
    return Center(
      child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MPresentMatrixSingleline(gridData: problemToList),
              SizedBox(height: hSize * 0.3),
              MInputList(
                itemCount: mathData.matrixVolume[5],
                recognitionZoneKeys: answerKeys,
                strokeList: answerStrokes[0],
              ),
            ],
          ),
    );
  }
}
