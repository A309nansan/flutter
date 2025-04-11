import 'package:flutter/material.dart';

class DrawingCanvas extends StatefulWidget {
  final double width;
  final double height;

  const DrawingCanvas({super.key, required this.width, required this.height});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  Offset? _cursorPosition; // 현재 커서 위치
  List<DrawnLine?> _lines = [];
  Color _currentColor = Colors.black;
  double _strokeWidth = 4.0;

  void _changeColor(Color color, {bool isEraser = false}) {
    setState(() {
      _currentColor = color;
      _strokeWidth = isEraser ? 40.0 : 4.0;
    });
  }

  void _clearCanvas() {
    setState(() {
      _lines = [];
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        // 🎨 색상/지우개/초기화
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(12 ),
            color: Color(0x11222222)
          ),
          child:        SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                GestureDetector(
                  onPanUpdate: (details) {
                    RenderBox box = context.findRenderObject() as RenderBox;
                    Offset localPos = box.globalToLocal(details.globalPosition);

                    // 캔버스 안에 있는 좌표인지 확인
                    if (localPos.dx >= 0 &&
                        localPos.dy >= 0 &&
                        localPos.dx <= widget.width &&
                        localPos.dy <= widget.height) {
                      setState(() {
                        _lines.add(DrawnLine(localPos, _currentColor, _strokeWidth));
                        _cursorPosition = localPos;
                      });
                    }
                  },
                  onPanEnd: (_) {
                    _lines.add(null);
                    setState(() {
                      _cursorPosition = null;
                    });
                  },
                  child: CustomPaint(
                    size: Size(widget.width, widget.height),
                    painter: DrawingPainter(_lines),
                  ),
                ),
                // 🧽 지우개 커서 표시 (흰색일 때만)
                if (_isEraserSelected && _cursorPosition != null)
                  Positioned(
                    left: _cursorPosition!.dx - _strokeWidth / 2,
                    top: _cursorPosition!.dy - _strokeWidth / 2,
                    child: Container(
                      width: _strokeWidth,
                      height: _strokeWidth,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ✍️ 캔버스 영역

        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            SizedBox(),
            Row(
              children:[
                _colorButton(Colors.black),
                _colorButton(Colors.red),
                _colorButton(Colors.blue),
                _eraserButton(),
              ]
            ),
            SizedBox(),
            ElevatedButton(
              onPressed: _clearCanvas,
              child: const Text('전체 지우기'),
            ),
            SizedBox(),
          ],
        ),

      ],
    );
  }

  Color _selectedColor = Colors.black;

  Widget _colorButton(Color color) {
    final bool isSelected = _selectedColor == color;

    return GestureDetector(
      onTap: () {
        _changeColor(color);
        setState(() {
          _selectedColor = color;
          _isEraserSelected = false;
        });
      },
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          // border: Border.all(
          //   color: isSelected ? Colors.black : Colors.grey.shade400,
          //   width: isSelected ? 3 : 1.5,
          // ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }
  bool _isEraserSelected = false;

  Widget _eraserButton() {
    final bool isSelected = _isEraserSelected;

    return GestureDetector(
      onTap: () {
        _changeColor(Colors.white, isEraser: true);
        setState(() {
          _selectedColor = Colors.white;
          _isEraserSelected = true;
        });
      },
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius:BorderRadius.circular(15),
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.grey : Colors.transparent,
            width: 1.5,
          ),

        ),
          child: Center(child:
          Image.asset(
            'assets/images/basa_math/eraser.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
          )
      ),
    );
  }
}

class DrawnLine {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  DrawnLine(this.offset, this.color, this.strokeWidth);
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine?> lines;

  DrawingPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < lines.length - 1; i++) {
      final current = lines[i];
      final next = lines[i + 1];
      if (current != null && next != null) {
        final paint = Paint()
          ..color = current.color
          ..strokeWidth = current.strokeWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(current.offset, next.offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}