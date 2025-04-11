import 'package:flutter/material.dart';
import 'dart:math'; // min() 함수 사용을 위해 추가

import '../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../utils/math_ui_constant.dart';

class MAnswerList extends StatelessWidget {
  final int itemCount; // 몇 개의 HandwritingRecognitionZone을 띄울지
  final List<String> recognizedResults;
  final List<String> expectedResults;

  final bool isShowingUserInput;

  const MAnswerList({
    Key? key,
    required this.itemCount,
    required this.recognizedResults, // GlobalKey 리스트를 받아서 상태 관리
    required this.expectedResults,
    required this.isShowingUserInput,
  }) : super(key: key);
  double get wSize => MathUIConstant.wSize;
  double get hSize => MathUIConstant.hSize;
  double get fSize => MathUIConstant.fSize;
  Color get marginColor => MathUIConstant.semiTransparentMarginColor;
  Color get rightColor => MathUIConstant.rightAnswerColor;
  Color get wrongColor => MathUIConstant.wrongAnswerColor;
  Color get textColor => MathUIConstant.blackFontColor;
  @override
  Widget build(BuildContext context) {
    int validItemCount = min(itemCount, recognizedResults.length);

    return IntrinsicWidth( child: Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: MathUIConstant.boundaryBlue, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
            Row(
              children: List.generate(validItemCount, (index) {
                return
                    Container(
                      width: wSize,
                      height: hSize,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: MathUIConstant.boundaryGreen,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Center(
                        child:Container(
                          width: wSize * 0.9,
                          height: hSize * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: marginColor,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center( child: !isShowingUserInput? Text(
                            expectedResults[index] == "-1"? "": expectedResults[index],
                            style: TextStyle(
                              fontSize: fSize,
                              fontWeight: FontWeight.bold,
                              color:
                              recognizedResults[index] == expectedResults[index]
                                  ? rightColor
                                  : wrongColor,
                            ),
                          ): Text(
                            recognizedResults[index] == "-1"? "": recognizedResults[index],
                            style: TextStyle(
                              fontSize: fSize,
                              fontWeight: FontWeight.bold,
                              color:
                              recognizedResults[index] == expectedResults[index]
                                  ? rightColor
                                  : wrongColor,
                            ),
                          ),),
                        )
                      ),
                      // 가운데 정렬


                    );
              }),
            ),
        ],
      ),
    ),);
  }
}
