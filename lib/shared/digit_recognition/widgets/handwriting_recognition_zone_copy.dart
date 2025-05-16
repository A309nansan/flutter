import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:screenshot/screenshot.dart';
import '../../../modules/math/src/utils/math_ui_constant.dart';
import '../services/recognition_service.dart';

// ML Kit 클래스 대체를 위한 커스텀 스트로크 구현
class StrokePoint {
  final double x;
  final double y;
  final int t;

  StrokePoint({required this.x, required this.y, required this.t});
  Map<String, dynamic> toJson() => {'x': x, 'y': y, 't': t};
}

class Stroke {
  final List<StrokePoint> points = [];
  List<Map<String, dynamic>> toJson() => points.map((p) => p.toJson()).toList();
}

class Ink {
  final List<Stroke> strokes = [];
  Map<String, dynamic> toJson() => {'strokes': strokes.map((s) => s.toJson()).toList()};
}

class HandwritingRecognitionZoneTest extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final Color? borderColor;
  final double strokeWidth;
  final Function(String)? onRecognized;
  final Function()? onRecognitionFailed;
  final bool enabled;
  final bool displayLoadingstate;
  final ScreenshotController controller;

  const HandwritingRecognitionZoneTest({
    super.key,
    required this.width,
    required this.height,
    required this.controller,
    this.backgroundColor = Colors.white54,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
    this.onRecognized,
    this.onRecognitionFailed,
    this.enabled = true,
    this.displayLoadingstate = true,
    this.borderColor,
  });

  @override
  HandwritingRecognitionZoneTestState createState() => HandwritingRecognitionZoneTestState();
}

class HandwritingRecognitionZoneTestState extends State<HandwritingRecognitionZoneTest> {
  final List<Stroke> _strokes = [];
  Stroke? _currentStroke;
  final Ink _ink = Ink();
  String _recognizedText = '';
  bool _isRecognizing = false;
  bool _recognitionFailed = false;
  Color _bgColor = Colors.white;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _bgColor = widget.backgroundColor;
    _enabled = widget.enabled;
  }

  void updateBackgroundColor(Color newColor) {
    setState(() => _bgColor = newColor);
  }

  void updateEnableState(bool newState) {
    setState(() => _enabled = newState);
  }

  void setStrokes(List<Stroke> strokes) {
    setState(() {
      _strokes.clear();
      _strokes.addAll(strokes);
      _ink.strokes.clear();
      _ink.strokes.addAll(strokes);
    });
  }

  List<Stroke> getStrokes() => _strokes.map((s) => Stroke()..points.addAll(s.points)).toList();

  Future<String> recognize() async {
    if (_strokes.isEmpty) return _recognizedText;
    setState(() => _isRecognizing = true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      setState(() {
        _isRecognizing = false;
        _recognitionFailed = false;
      });

      widget.onRecognized?.call(_recognizedText);
      return _recognizedText;
    } catch (e) {
      setState(() {
        _isRecognizing = false;
        _recognizedText = "?";
        _recognitionFailed = true;
      });
      widget.onRecognitionFailed?.call();
      return _recognizedText;
    }
  }

  void _sendDataToServer() async {
    final childProfileJson = await SecureStorageService.getChildProfile();
    final childProfile = jsonDecode(childProfileJson!);
    final int childId = childProfile['id'];
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _ink.strokes.clear();
      _recognizedText = '';
      _recognitionFailed = false;
    });
  }

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
      absorbing: !_enabled,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _enabled
              ? (_recognitionFailed ? Colors.red.shade200 : _bgColor)
              : Colors.grey[300],
          border: Border.all(
            color: _recognitionFailed
                ? Colors.red
                : (widget.borderColor ?? MathUIConstant.inputBoundaryColor),
            width: _recognitionFailed ? 3.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Screenshot(
          controller: widget.controller,
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
                if (_isRecognizing && widget.displayLoadingstate)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    setState(() {
      _currentStroke = Stroke();
      _currentStroke!.points.add(StrokePoint(
        x: point.dx,
        y: point.dy,
        t: DateTime.now().millisecondsSinceEpoch,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentStroke == null) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    setState(() {
      _currentStroke!.points.add(StrokePoint(
        x: point.dx,
        y: point.dy,
        t: DateTime.now().millisecondsSinceEpoch,
      ));
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
    final Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }
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
