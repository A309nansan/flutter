import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

class DrawingPainter extends CustomPainter {
  final List<List<DrawingPoint>> lines;
  DrawingPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());

    for (final line in lines) {
      if (line.isEmpty) continue;
      final path = Path();
      for (int i = 0; i < line.length; i++) {
        if (i == 0) {
          path.moveTo(line[i].point.dx, line[i].point.dy);
        } else {
          path.lineTo(line[i].point.dx, line[i].point.dy);
        }
      }
      canvas.drawPath(path, line.first.paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}