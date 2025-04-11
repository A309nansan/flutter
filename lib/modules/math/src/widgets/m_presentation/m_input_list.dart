import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'dart:math'; // min() 함수 사용을 위해 추가

import '../../../../../shared/digit_recognition/widgets/handwriting_recognition_zone.dart';
import '../../utils/math_ui_constant.dart';

class MInputList extends StatefulWidget {
  final int itemCount; // 몇 개의 HandwritingRecognitionZone을 띄울지
  final Function(List<String>)? onAllRecognized; // 상위로 인식 결과 전달 콜백 (옵션)
  final List<GlobalKey<HandwritingRecognitionZoneState>> recognitionZoneKeys;
  final List<List<Stroke>> strokeList;

  const MInputList({
    Key? key,
    required this.itemCount,
    required this.recognitionZoneKeys, // GlobalKey 리스트를 받아서 상태 관리
    required this.strokeList,
    this.onAllRecognized,
  }) : super(key: key);
  double get wSize => MathUIConstant.wSize;
  double get hSize => MathUIConstant.hSize;
  @override
  State<MInputList> createState() => _MInputListState();
}

class _MInputListState extends State<MInputList> {
  late List<String> recognizedResults;
  late List<List<Stroke>> strokeResults;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      int validItemCount = min(widget.itemCount, widget.recognitionZoneKeys.length);

      // 숫자 결과 초기화
      recognizedResults = List.generate(validItemCount, (i) {
        final state = widget.recognitionZoneKeys[i].currentState;

        // 🔥 기존 strokeList가 존재하면 복원해줌
        if (widget.strokeList.isNotEmpty && widget.strokeList.length > i) {
          final strokes = widget.strokeList[i];  // 또는 strokeList[i]로 설계에 따라
          state?.setStrokes(strokes);
        }

        return state?.recognizedText ?? '';
      });

      // strokeResults도 업데이트
      strokeResults = List.generate(validItemCount, (i) {
        final state = widget.recognitionZoneKeys[i].currentState;
        return state?.getStrokes() ?? [];
      });

      print("✅ Stroke 복원 완료");
      widget.onAllRecognized?.call(recognizedResults);
    });
  }

  void _onRecognitionChanged(int index, String recognizedText) {
    setState(() {
      recognizedResults[index] = recognizedText; // 해당 index의 값 업데이트
      // 🆕 stroke도 새로 가져와서 업데이트
      final state = widget.recognitionZoneKeys[index].currentState;
      if (state != null) {
        strokeResults[index] = state.getStrokes();
      }
    });

    // 모든 인식 결과를 상위 위젯으로 전달
    if (widget.onAllRecognized != null) {
      widget.onAllRecognized!(recognizedResults);
    }
  }

  @override
  Widget build(BuildContext context) {
    int validItemCount = min(widget.itemCount, widget.recognitionZoneKeys.length);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: MathUIConstant.boundaryTeal,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: List.generate(validItemCount, (index) {
              return Container(
                width: widget.wSize,
                height: widget.hSize,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: MathUIConstant.boundaryTransparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center( // 🧡 정중앙에 배치
                  child: HandwritingRecognitionZone(
                    key: widget.recognitionZoneKeys[index],
                    width: widget.wSize * 0.9,
                    height: widget.hSize * 0.9,
                    backgroundColor: Colors.transparent,
                    strokeColor: Colors.black,
                    strokeWidth: 3.0,
                    displayLoadingstate: false,
                    onRecognized: (recognizedText) {
                      _onRecognitionChanged(index, recognizedText);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
void printOneStroke(List<Stroke> strokeData) {

      for (int k = 0; k < strokeData.length; k++) {
        final stroke = strokeData[k];
        print('  Stroke $k:');

      }


}
