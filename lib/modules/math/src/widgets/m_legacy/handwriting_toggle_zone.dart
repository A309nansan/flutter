// import 'package:flutter/material.dart';
// import 'handwriting_recognition_zone.dart';
// import 'handwriting_finished_zone.dart';
//
// class HandwritingToggleZone extends StatefulWidget {
//   final double width;
//   final double height;
//   final Color backgroundColor;
//   final Color strokeColor;
//   final double strokeWidth;
//   final Function(String)? onRecognized;
//
//   const HandwritingToggleZone({
//     Key? key,
//     required this.width,
//     required this.height,
//     required this.backgroundColor,
//     required this.strokeColor,
//     required this.strokeWidth,
//     this.onRecognized,
//   }) : super(key: key);
//
//   @override
//   State<HandwritingToggleZone> createState() => _HandwritingToggleZoneState();
// }
//
// class _HandwritingToggleZoneState extends State<HandwritingToggleZone> {
//   bool _isFinished = false;       // true면 HandwritingFinishedZone 표시
//   String _recognizedText = '';    // 인식 결과
//
//   // HandwritingRecognitionZone을 제어하기 위한 Key
//   final GlobalKey<HandwritingRecognitionZoneState> _recognitionKey = GlobalKey();
//
//   void _handleRecognized(String text) {
//     setState(() {
//       _recognizedText = text;
//       _isFinished = true;
//     });
//
//     // 상위 위젯이 존재하면 인식된 결과 전달
//     if (widget.onRecognized != null) {
//       widget.onRecognized!(text);
//     }
//   }
//
//   void _handleErase() {
//     setState(() {
//       // 다시 그리는 모드로 전환
//       _isFinished = false;
//       _recognizedText = '';
//       // 실제 필기 내용을 지우려면 아래 메서드 호출
//       _recognitionKey.currentState?.clear();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // _isFinished 상태에 따라 다른 위젯 보여줌
//     return _isFinished
//         ? HandwritingFinishedZone(
//       width: widget.width,
//       height: widget.height,
//       recognizedText: _recognizedText,
//       onErase: _handleErase,
//     )
//         : HandwritingRecognitionZone(
//       key: _recognitionKey,
//       width: widget.width,
//       height: widget.height,
//       backgroundColor: widget.backgroundColor,
//       strokeColor: widget.strokeColor,
//       strokeWidth: widget.strokeWidth,
//       onRecognized: _handleRecognized,
//     );
//   }
// }
