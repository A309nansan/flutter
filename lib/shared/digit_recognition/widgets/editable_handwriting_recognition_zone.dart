import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import '../services/recognition_service.dart';

class EditableHandwritingRecognitionZone extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final double strokeWidth;
  final Function(String)? onRecognized;
  final Function()? onRecognitionFailed;

  // 테두리 커스터마이징을 위한 속성 추가
  final BoxBorder? border;

  // BorderRadius를 필수(required)로 설정
  final BorderRadiusGeometry borderRadius;

  // 인식 실패 시 사용할 스타일 속성
  final BoxBorder? failureBorder;
  final Color? failureBackgroundColor;

  const EditableHandwritingRecognitionZone({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius, // 필수 속성으로 변경
    this.backgroundColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
    this.onRecognized,
    this.onRecognitionFailed,
    this.border,
    this.failureBorder,
    this.failureBackgroundColor,
  });

  @override
  EditableHandwritingRecognitionZoneState createState() =>
      EditableHandwritingRecognitionZoneState();
}

class EditableHandwritingRecognitionZoneState
    extends State<EditableHandwritingRecognitionZone> {
  final List<Stroke> _strokes = [];
  Stroke? _currentStroke;
  final Ink _ink = Ink();
  String _recognizedText = '';
  bool _isRecognizing = false;
  bool _recognitionFailed = false;

  String get recognizedText => _recognizedText;

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
          _recognizedText = candidates.first.text;
          _recognitionFailed = false;
        } else {
          _recognizedText = "?";
          _recognitionFailed = true;

          if (widget.onRecognitionFailed != null) {
            widget.onRecognitionFailed!();
          }
        }
        _isRecognizing = false;
      });

      if (widget.onRecognized != null) {
        widget.onRecognized!(_recognizedText);
      }

      return _recognizedText;
    } catch (e) {
      setState(() {
        _isRecognizing = false;
        _recognizedText = "?";
        _recognitionFailed = true;

        if (widget.onRecognitionFailed != null) {
          widget.onRecognitionFailed!();
        }
      });
      return _recognizedText;
    }
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
    // 인식 실패 여부에 따라 적절한 스타일 결정
    final BoxBorder effectiveBorder =
        _recognitionFailed
            ? (widget.failureBorder ??
                Border.all(color: Colors.red, width: 3.0))
            : (widget.border ?? Border.all(color: Colors.grey, width: 1.0));

    // 인식 실패 시에도 기존 borderRadius를 사용하도록 설정
    final BorderRadiusGeometry effectiveBorderRadius =
        widget.borderRadius; // 항상 기존 borderRadius를 사용

    final Color effectiveBackgroundColor =
        _recognitionFailed
            ? (widget.failureBackgroundColor ?? Colors.red.shade200)
            : widget.backgroundColor;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        border: effectiveBorder,
        borderRadius: effectiveBorderRadius,
      ),
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
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
            if (_isRecognizing) Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

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
