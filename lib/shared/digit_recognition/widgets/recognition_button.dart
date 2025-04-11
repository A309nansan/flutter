import 'package:flutter/material.dart';
import 'handwriting_recognition_zone.dart';

class RecognitionButton extends StatefulWidget {
  final List<GlobalKey<HandwritingRecognitionZoneState>> recognitionZoneKeys;
  final String buttonText;
  final Color buttonColor;
  final Color textColor;
  final VoidCallback? onRecognitionComplete;

  const RecognitionButton({
    super.key,
    required this.recognitionZoneKeys,
    this.buttonText = '인식하기',
    this.buttonColor = Colors.blue,
    this.textColor = Colors.white,
    this.onRecognitionComplete,
  });

  @override
  RecognitionButtonState createState() => RecognitionButtonState();
}

class RecognitionButtonState extends State<RecognitionButton> {
  bool _isRecognizing = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          _isRecognizing
              ? null
              : () async {
                setState(() {
                  _isRecognizing = true;
                });

                // 모든 인식 영역 처리
                for (final zoneKey in widget.recognitionZoneKeys) {
                  if (zoneKey.currentState != null) {
                    await zoneKey.currentState!.recognize();
                  }
                }

                setState(() {
                  _isRecognizing = false;
                });

                // 인식 완료 후 콜백
                if (widget.onRecognitionComplete != null) {
                  widget.onRecognitionComplete!();
                }
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.buttonColor,
        foregroundColor: widget.textColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child:
          _isRecognizing
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(widget.textColor),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('인식 중...'),
                ],
              )
              : Text(widget.buttonText, style: TextStyle(fontSize: 16)),
    );
  }
}
