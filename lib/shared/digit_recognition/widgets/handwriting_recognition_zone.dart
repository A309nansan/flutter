import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import '../../../modules/math/src/utils/math_ui_constant.dart';
import '../services/recognition_service.dart';

class HandwritingRecognitionZone extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final Color? borderColor; // nullable로!
  final double strokeWidth;
  final Function(String)? onRecognized;
  final Function()? onRecognitionFailed; // 인식 실패 시 콜백 추가
  final bool enabled;
  final bool displayLoadingstate;
  const HandwritingRecognitionZone({
    super.key,
    required this.width,
    required this.height,
    this.backgroundColor = Colors.white54,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
    this.onRecognized,
    this.onRecognitionFailed, // 인식 실패 콜백 추가
    this.enabled = true,
    this.displayLoadingstate = true,
    this.borderColor,
  });

  @override
  HandwritingRecognitionZoneState createState() =>
      HandwritingRecognitionZoneState();
}

class HandwritingRecognitionZoneState
    extends State<HandwritingRecognitionZone> {
  final List<Stroke> _strokes = [];
  Stroke? _currentStroke;
  final Ink _ink = Ink();
  String _recognizedText = '';
  bool _isRecognizing = false;
  bool _recognitionFailed = false; // 인식 실패 상태 추가
  Color _bgColor = Colors.white; // 기본값, 필요에 따라 변경 가능
  // 인식된 텍스트 가져오기
  bool _enabled = true;
  String get recognizedText => _recognizedText;
  Color get bgColor => _bgColor;
  bool get enabled => _enabled;

  void updateBackgroundColor(Color newColor) {
    setState(() {
      _bgColor = newColor;
    });
  }

  void updateEnableState(bool newState) {
    setState(() {
      _enabled = newState;
    });
  }

  void setStrokes(List<Stroke> strokes) {
    setState(() {
      _strokes.clear();
      _strokes.addAll(strokes);
      _ink.strokes.clear();
      _ink.strokes.addAll(strokes);
    });
  }

  List<Stroke> getStrokes() {
    return _strokes.map((s) => Stroke()..points.addAll(s.points)).toList();
  }

  @override
  void initState() {
    super.initState();
    _bgColor = widget.backgroundColor;
    _enabled = widget.enabled;
  }

  // 인식 프로세스 실행
  Future<String> recognize() async {
    if (_strokes.isEmpty) return _recognizedText;

    setState(() {
      _isRecognizing = true;
    });

    try {
      final candidates = await DigitalInkRecognitionService.instance.recognize(
        _ink,
      );

      setState(() {
        if (candidates.isNotEmpty) {
          // 첫 번째(가장 확률이 높은) 숫자 결과 사용
          _recognizedText = candidates.first.text;
          _recognitionFailed = false;
        } else {
          // 숫자 인식 결과가 없는 경우 '?' 설정
          _recognizedText = "?";
          _recognitionFailed = true;

          // 인식 실패 콜백 호출
          if (widget.onRecognitionFailed != null) {
            widget.onRecognitionFailed!();
          }
        }
        _isRecognizing = false;
      });

      // 콜백 실행
      if (widget.onRecognized != null) {
        widget.onRecognized!(_recognizedText);
      }

      return _recognizedText;
    } catch (e) {
      setState(() {
        _isRecognizing = false;
        _recognizedText = "?";
        _recognitionFailed = true;

        // 인식 실패 콜백 호출
        if (widget.onRecognitionFailed != null) {
          widget.onRecognitionFailed!();
        }
      });
      return _recognizedText;
    }
  }

  // 그림과 인식 결과 지우기
  void clear() {
    setState(() {
      _strokes.clear();
      _ink.strokes.clear();
      _recognizedText = '';
      _recognitionFailed = false;
    });
  }

  // 마지막 획 지우기
  void eraseLastStroke() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
        _ink.strokes.removeLast();
        _recognizedText = '';
        _recognitionFailed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !_enabled, // 터치 막기
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color:
              _enabled
                  ? (_recognitionFailed ? Colors.red.shade200 : _bgColor)
                  : Colors.grey[300], // 비활성 상태일 때 배경 회색
          border: Border.all(
            color:
                _recognitionFailed
                    ? Colors.red
                    : (widget.borderColor ?? MathUIConstant.inputBoundaryColor),
            width: _recognitionFailed ? 3.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onLongPress: () {
            clear();
            updateBackgroundColor(Colors.transparent);
          },
          onPanDown: (_) {},
          child: Stack(
            children: [
              CustomPaint(
                size: Size(widget.width, widget.height),
                painter: _InkPainter(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                  strokeColor: widget.strokeColor,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              // if (_isRecognizing)
              //   const Center(child: CircularProgressIndicator()),
              if (_isRecognizing && widget.displayLoadingstate)  const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     width: widget.width,
  //     height: widget.height,
  //     decoration: BoxDecoration(
  //       color:
  //           _recognitionFailed
  //               ? Colors.red.withOpacity(0.1)
  //               : bgColor,
  //       border: Border.all(
  //         //color: _recognitionFailed ? Colors.red : Colors.grey,
  //         //width: _recognitionFailed ? 3.0 : 1.0,
  //         color: _recognitionFailed ? Colors.red : MathUIConstant.inputBoundaryColor,
  //         width: _recognitionFailed ? 3.0 : 1.5,
  //       ),
  //       borderRadius: BorderRadius.circular(8.0),
  //     ),
  //     child: GestureDetector(
  //       onPanStart: _onPanStart,
  //       onPanUpdate: _onPanUpdate,
  //       onPanEnd: _onPanEnd,
  //
  //       onLongPress: () {
  //         clear(); // ✅ 롱프레스 시 모든 필기 초기화
  //         updateBackgroundColor(Colors.transparent);
  //       },
  //
  //       onPanDown: (_) {},
  //
  //       child: Stack(
  //         children: [
  //           CustomPaint(
  //             size: Size(widget.width, widget.height),
  //             painter: _InkPainter(
  //               strokes: _strokes,
  //               currentStroke: _currentStroke,
  //               strokeColor: widget.strokeColor,
  //               strokeWidth: widget.strokeWidth,
  //             ),
  //           ),
  //           if (_isRecognizing && widget.displayLoadingstate) Center(child: CircularProgressIndicator()),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _onPanStart(DragStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    setState(() {
      _currentStroke = Stroke();
      final strokePoint = StrokePoint(
        x: point.dx,
        y: point.dy,
        t: DateTime.now().millisecondsSinceEpoch,
      );
      _currentStroke!.points.add(strokePoint);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentStroke == null) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    setState(() {
      final strokePoint = StrokePoint(
        x: point.dx,
        y: point.dy,
        t: DateTime.now().millisecondsSinceEpoch,
      );
      _currentStroke!.points.add(strokePoint);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke == null) return;
    setState(() {
      _strokes.add(_currentStroke!);
      _ink.strokes.add(_currentStroke!);
      _currentStroke = null;
    });
  }
}

class _InkPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;
  final Color strokeColor;
  final double strokeWidth;

  _InkPainter({
    required this.strokes,
    this.currentStroke,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    // 완료된 획 그리기
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }

    // 현재 획 그리기
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!, paint);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.isEmpty) return;
    final Path path = Path();
    path.moveTo(stroke.points.first.x, stroke.points.first.y);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].x, stroke.points[i].y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_InkPainter oldDelegate) => true;
}
