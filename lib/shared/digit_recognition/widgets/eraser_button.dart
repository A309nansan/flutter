import 'package:flutter/material.dart';
import 'handwriting_recognition_zone.dart';

class EraserButton extends StatelessWidget {
  final List<GlobalKey<HandwritingRecognitionZoneState>> recognitionZoneKeys;
  final Color buttonColor;
  final Color textColor;

  const EraserButton({
    super.key,
    required this.recognitionZoneKeys,
    this.buttonColor = Colors.red,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // 각 인식 영역의 마지막 획 지우기
        for (final zoneKey in recognitionZoneKeys) {
          if (zoneKey.currentState != null) {
            zoneKey.currentState!.eraseLastStroke();
          }
        }
      },
      icon: Icon(Icons.auto_fix_normal, color: textColor),
      label: Text('지우기', style: TextStyle(color: textColor)),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
