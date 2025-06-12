import 'package:flutter/material.dart';

class StrokePreviewPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  StrokePreviewPainter(this.strokeWidth, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant StrokePreviewPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth || oldDelegate.color != color;
  }
}